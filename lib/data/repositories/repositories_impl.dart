// lib/data/repositories/repositories_impl.dart
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/repositories/quiz_result_repository.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/quiz_result_model.dart';
import '../models/user_model.dart';

// ─── Auth Repository Implementation ────────────────────────

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Future<(UserEntity?, Failure?)> login(String email, String password) async {
    try {
      final user = await dataSource.login(email, password);
      if (user == null)
        return (null, const AuthFailure('Invalid email or password'));
      await dataSource.saveLoggedInUser(user.id!);
      return (user, null);
    } catch (e) {
      return (null, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(UserEntity?, Failure?)> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final user = await dataSource.register(name, email, password);
      if (user == null)
        return (null, const AuthFailure('Email already in use'));
      await dataSource.saveLoggedInUser(user.id!);
      return (user, null);
    } catch (e) {
      return (null, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(UserEntity?, Failure?)> getUserById(int id) async {
    try {
      final user = await dataSource.getUserById(id);
      if (user == null) return (null, const NotFoundFailure('User not found'));
      return (user, null);
    } catch (e) {
      return (null, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> updateUser(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      final ok = await dataSource.updateUser(model);
      return (ok, ok ? null : const DatabaseFailure('Update failed'));
    } catch (e) {
      return (false, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() => dataSource.clearLoggedInUser();

  @override
  Future<int?> getLoggedInUserId() => dataSource.getLoggedInUserId();
}

// ─── Subject Repository Implementation ────────────────────

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource dataSource;
  SubjectRepositoryImpl(this.dataSource);

  @override
  Future<(List<SubjectEntity>, Failure?)> getAllSubjects() async {
    try {
      final subjects = await dataSource.getAllSubjects();
      return (subjects as List<SubjectEntity>, null);
    } catch (e) {
      return (<SubjectEntity>[], DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(List<SubjectEntity>, Failure?)> getFavoriteSubjects(
    int userId,
  ) async {
    try {
      final subjects = await dataSource.getFavoriteSubjects(userId);
      return (subjects as List<SubjectEntity>, null);
    } catch (e) {
      return (<SubjectEntity>[], DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> toggleFavorite(int userId, int subjectId) async {
    try {
      final added = await dataSource.toggleFavorite(userId, subjectId);
      return (added, null);
    } catch (e) {
      return (false, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<bool> isFavorite(int userId, int subjectId) =>
      dataSource.isFavorite(userId, subjectId);
}

// ─── Question Repository Implementation ───────────────────

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionLocalDataSource dataSource;
  QuestionRepositoryImpl(this.dataSource);

  @override
  Future<(List<QuestionEntity>, Failure?)> getQuestionsBySubject(
    int subjectId,
  ) async {
    try {
      final questions = await dataSource.getQuestionsBySubject(subjectId);
      return (questions as List<QuestionEntity>, null);
    } catch (e) {
      return (<QuestionEntity>[], DatabaseFailure(e.toString()));
    }
  }
}

// ─── Quiz Result Repository Implementation ────────────────

class QuizResultRepositoryImpl implements QuizResultRepository {
  final QuizResultLocalDataSource dataSource;
  QuizResultRepositoryImpl(this.dataSource);

  @override
  Future<(bool, Failure?)> saveResult(QuizResultEntity result) async {
    try {
      final model = QuizResultModel.fromEntity(result);
      final ok = await dataSource.saveResult(model);
      return (ok, ok ? null : const DatabaseFailure('Failed to save result'));
    } catch (e) {
      return (false, DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(List<QuizResultEntity>, Failure?)> getResultsByUser(
    int userId,
  ) async {
    try {
      final results = await dataSource.getResultsByUser(userId);
      return (results as List<QuizResultEntity>, null);
    } catch (e) {
      return (<QuizResultEntity>[], DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>, Failure?)> getUserStats(int userId) async {
    try {
      final stats = await dataSource.getUserStats(userId);
      return (stats, null);
    } catch (e) {
      return (<String, dynamic>{}, DatabaseFailure(e.toString()));
    }
  }
}
