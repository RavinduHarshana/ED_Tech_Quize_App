// lib/data/datasources/local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/hash_util.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final DatabaseHelper db;
  AuthLocalDataSource(this.db);

  Future<UserModel?> login(String email, String password) async {
    final rows = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (rows.isEmpty) return null;
    final user = UserModel.fromMap(rows.first);
    if (!HashUtil.verifyPassword(password, user.passwordHash)) return null;
    return user;
  }

  Future<UserModel?> register(
    String name,
    String email,
    String password,
  ) async {
    final existing = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existing.isNotEmpty) return null;

    final now = DateTime.now().toIso8601String();
    final user = UserModel(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: HashUtil.hashPassword(password),
      xpPoints: 0,
      trophyCount: 0,
      role: 0,
      createdAt: now,
    );
    final id = await db.insert(AppConstants.usersTable, user.toMap());
    return UserModel.fromMap({...user.toMap(), 'id': id});
  }

  Future<UserModel?> getUserById(int id) async {
    final rows = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<bool> updateUser(UserModel user) async {
    final count = await db.update(
      AppConstants.usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return count > 0;
  }

  Future<void> saveLoggedInUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.loggedInUserKey, userId);
  }

  Future<void> clearLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.loggedInUserKey);
  }

  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.loggedInUserKey);
  }
}

class SubjectLocalDataSource {
  final DatabaseHelper db;
  SubjectLocalDataSource(this.db);

  Future<List<SubjectModel>> getAllSubjects() async {
    final rows = await db.rawQuery('''
      SELECT s.id, s.name, s.icon, s.color_hex,
             COUNT(q.id) AS total_questions
      FROM ${AppConstants.subjectsTable} s
      LEFT JOIN ${AppConstants.questionsTable} q ON s.id = q.subject_id
      GROUP BY s.id, s.name, s.icon, s.color_hex
      ORDER BY s.name ASC
    ''');
    return rows.map(SubjectModel.fromMap).toList();
  }

  Future<SubjectModel?> getSubjectById(int id) async {
    final rows = await db.query(
      AppConstants.subjectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return SubjectModel.fromMap(rows.first);
  }

  Future<int> createSubject(SubjectModel subject) async {
    final payload = subject.toMap()..remove('id');
    return db.insert(AppConstants.subjectsTable, payload);
  }

  Future<bool> updateSubject(SubjectModel subject) async {
    final count = await db.update(
      AppConstants.subjectsTable,
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
    return count > 0;
  }

  Future<bool> deleteSubject(int subjectId) async {
    final database = await db.database;
    return database.transaction((txn) async {
      await txn.delete(
        AppConstants.favoritesTable,
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );
      await txn.delete(
        AppConstants.quizResultsTable,
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );
      await txn.delete(
        AppConstants.questionsTable,
        where: 'subject_id = ?',
        whereArgs: [subjectId],
      );
      final count = await txn.delete(
        AppConstants.subjectsTable,
        where: 'id = ?',
        whereArgs: [subjectId],
      );
      return count > 0;
    });
  }

  Future<List<SubjectModel>> getFavoriteSubjects(int userId) async {
    final rows = await db.rawQuery(
      '''
      SELECT s.id, s.name, s.icon, s.color_hex,
             COUNT(q.id) AS total_questions
      FROM ${AppConstants.subjectsTable} s
      LEFT JOIN ${AppConstants.questionsTable} q ON s.id = q.subject_id
      INNER JOIN ${AppConstants.favoritesTable} f ON s.id = f.subject_id
      WHERE f.user_id = ?
      GROUP BY s.id, s.name, s.icon, s.color_hex
      ORDER BY s.name ASC
    ''',
      [userId],
    );
    return rows.map(SubjectModel.fromMap).toList();
  }

  Future<bool> isFavorite(int userId, int subjectId) async {
    final rows = await db.query(
      AppConstants.favoritesTable,
      where: 'user_id = ? AND subject_id = ?',
      whereArgs: [userId, subjectId],
    );
    return rows.isNotEmpty;
  }

  Future<bool> toggleFavorite(int userId, int subjectId) async {
    final exists = await isFavorite(userId, subjectId);
    if (exists) {
      await db.delete(
        AppConstants.favoritesTable,
        where: 'user_id = ? AND subject_id = ?',
        whereArgs: [userId, subjectId],
      );
      return false;
    } else {
      await db.insert(AppConstants.favoritesTable, {
        'user_id': userId,
        'subject_id': subjectId,
      });
      return true;
    }
  }
}

class QuestionLocalDataSource {
  final DatabaseHelper db;
  QuestionLocalDataSource(this.db);

  Future<List<QuestionModel>> getQuestionsBySubject(int subjectId) async {
    final rows = await db.query(
      AppConstants.questionsTable,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'id ASC',
    );
    return rows.map(QuestionModel.fromMap).toList();
  }

  Future<List<QuestionModel>> getAllQuestions() async {
    final rows = await db.query(
      AppConstants.questionsTable,
      orderBy: 'subject_id ASC, id ASC',
    );
    return rows.map(QuestionModel.fromMap).toList();
  }

  Future<QuestionModel?> getQuestionById(int questionId) async {
    final rows = await db.query(
      AppConstants.questionsTable,
      where: 'id = ?',
      whereArgs: [questionId],
    );
    if (rows.isEmpty) return null;
    return QuestionModel.fromMap(rows.first);
  }

  Future<int> createQuestion(QuestionModel question) async {
    final payload = question.toMap()..remove('id');
    final id = await db.insert(AppConstants.questionsTable, payload);
    await _syncSubjectQuestionCount(question.subjectId);
    return id;
  }

  Future<bool> updateQuestion(QuestionModel question) async {
    final existing = await getQuestionById(question.id!);
    final count = await db.update(
      AppConstants.questionsTable,
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
    if (existing != null) {
      await _syncSubjectQuestionCount(existing.subjectId);
      if (existing.subjectId != question.subjectId) {
        await _syncSubjectQuestionCount(question.subjectId);
      }
    }
    return count > 0;
  }

  Future<bool> deleteQuestion(int questionId) async {
    final existing = await getQuestionById(questionId);
    final count = await db.delete(
      AppConstants.questionsTable,
      where: 'id = ?',
      whereArgs: [questionId],
    );
    if (existing != null) {
      await _syncSubjectQuestionCount(existing.subjectId);
    }
    return count > 0;
  }

  Future<void> _syncSubjectQuestionCount(int subjectId) async {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total_questions FROM ${AppConstants.questionsTable} WHERE subject_id = ?',
      [subjectId],
    );
    final totalQuestions =
        (rows.isNotEmpty ? rows.first['total_questions'] : 0) as int? ?? 0;
    await db.update(
      AppConstants.subjectsTable,
      {'total_questions': totalQuestions},
      where: 'id = ?',
      whereArgs: [subjectId],
    );
  }
}

class QuizResultLocalDataSource {
  final DatabaseHelper db;
  QuizResultLocalDataSource(this.db);

  Future<bool> saveResult(QuizResultModel result) async {
    final id = await db.insert(AppConstants.quizResultsTable, result.toMap());
    return id > 0;
  }

  Future<List<QuizResultModel>> getResultsByUser(int userId) async {
    final rows = await db.query(
      AppConstants.quizResultsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'taken_at DESC',
    );
    return rows.map(QuizResultModel.fromMap).toList();
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final results = await getResultsByUser(userId);
    if (results.isEmpty) {
      return {
        'quizzes_done': 0,
        'avg_score': 0,
        'best_score': 0,
        'total_correct': 0,
      };
    }
    final total = results.length;
    final avgScore =
        results.map((r) => r.scorePct).reduce((a, b) => a + b) ~/ total;
    final bestScore = results
        .map((r) => r.scorePct)
        .reduce((a, b) => a > b ? a : b);
    final totalCorrect = results.map((r) => r.correct).reduce((a, b) => a + b);
    return {
      'quizzes_done': total,
      'avg_score': avgScore,
      'best_score': bestScore,
      'total_correct': totalCorrect,
    };
  }
}
