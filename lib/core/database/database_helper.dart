// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../utils/hash_util.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        avatar_path TEXT,
        xp_points INTEGER DEFAULT 0,
        trophy_count INTEGER DEFAULT 0,
        role INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Subjects table
    await db.execute('''
      CREATE TABLE ${AppConstants.subjectsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        total_questions INTEGER DEFAULT 0,
        color_hex TEXT NOT NULL
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE ${AppConstants.questionsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_index INTEGER NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES ${AppConstants.subjectsTable}(id)
      )
    ''');

    // Quiz results table
    await db.execute('''
      CREATE TABLE ${AppConstants.quizResultsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        subject_name TEXT NOT NULL,
        correct INTEGER NOT NULL,
        total INTEGER NOT NULL,
        score_pct INTEGER NOT NULL,
        taken_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id),
        FOREIGN KEY (subject_id) REFERENCES ${AppConstants.subjectsTable}(id)
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE ${AppConstants.favoritesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        UNIQUE(user_id, subject_id),
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id),
        FOREIGN KEY (subject_id) REFERENCES ${AppConstants.subjectsTable}(id)
      )
    ''');

    // Seed data
    await _seedSubjects(db);
    await _seedQuestions(db);
    await _seedDefaultUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE ${AppConstants.usersTable} ADD COLUMN role INTEGER DEFAULT 0',
      );
      await db.update(
        AppConstants.usersTable,
        {'password_hash': HashUtil.hashPassword('124'), 'role': 0},
        where: 'email = ?',
        whereArgs: ['user@example.com'],
      );
    }
    await _seedDefaultUsers(db, overwrite: false);
  }

  Future<void> _seedDefaultUsers(Database db, {bool overwrite = true}) async {
    if (overwrite) {
      await db.delete(AppConstants.usersTable);
    }

    final now = DateTime.now().toIso8601String();
    final users = [
      {
        'name': 'User',
        'email': 'user@example.com',
        'password_hash': HashUtil.hashPassword('124'),
        'xp_points': 100,
        'trophy_count': 5,
        'role': 0,
        'created_at': now,
      },
      {
        'name': 'Admin',
        'email': 'admin@example.com',
        'password_hash': HashUtil.hashPassword('admin123'),
        'xp_points': 0,
        'trophy_count': 0,
        'role': 1,
        'created_at': now,
      },
    ];

    for (final user in users) {
      final exists = await db.query(
        AppConstants.usersTable,
        where: 'email = ?',
        whereArgs: [user['email']],
      );
      if (exists.isEmpty) {
        await db.insert(AppConstants.usersTable, user);
      }
    }
  }

  Future<void> _seedSubjects(Database db) async {
    final subjects = [
      {
        'name': 'Biology',
        'icon': 'B',
        'total_questions': 9,
        'color_hex': '7C3AED',
      },
      {
        'name': 'Mathematics',
        'icon': 'M',
        'total_questions': 4,
        'color_hex': 'F59E0B',
      },
      {
        'name': 'Foreign Language',
        'icon': 'F',
        'total_questions': 3,
        'color_hex': 'A855F7',
      },
      {
        'name': 'History',
        'icon': 'H',
        'total_questions': 4,
        'color_hex': 'EC4899',
      },
      {
        'name': 'Physics',
        'icon': 'P',
        'total_questions': 4,
        'color_hex': '06B6D4',
      },
      {
        'name': 'Chemistry',
        'icon': 'C',
        'total_questions': 3,
        'color_hex': '10B981',
      },
    ];

    for (final s in subjects) {
      await db.insert(AppConstants.subjectsTable, s);
    }
  }

  Future<void> _seedQuestions(Database db) async {
    final questions = [
      // Biology (subject_id = 1)
      {
        'subject_id': 1,
        'text': 'Which is a mammalian animal?',
        'option_a': 'Elephant',
        'option_b': 'Crocodile',
        'option_c': 'Eagle',
        'option_d': 'Salmon',
        'correct_index': 0,
      },
      {
        'subject_id': 1,
        'text': 'The powerhouse of the cell is?',
        'option_a': 'Nucleus',
        'option_b': 'Mitochondria',
        'option_c': 'Ribosome',
        'option_d': 'Golgi',
        'correct_index': 1,
      },
      {
        'subject_id': 1,
        'text': 'How many chromosomes in human cells?',
        'option_a': '23',
        'option_b': '46',
        'option_c': '48',
        'option_d': '44',
        'correct_index': 1,
      },
      {
        'subject_id': 1,
        'text': 'Which blood type is the universal donor?',
        'option_a': 'A+',
        'option_b': 'B+',
        'option_c': 'O-',
        'option_d': 'AB+',
        'correct_index': 2,
      },
      {
        'subject_id': 1,
        'text': 'Photosynthesis occurs in which organelle?',
        'option_a': 'Vacuole',
        'option_b': 'Lysosome',
        'option_c': 'Chloroplast',
        'option_d': 'Nucleus',
        'correct_index': 2,
      },
      {
        'subject_id': 1,
        'text': 'What is the basic unit of life?',
        'option_a': 'Tissue',
        'option_b': 'Organ',
        'option_c': 'Cell',
        'option_d': 'Molecule',
        'correct_index': 2,
      },
      {
        'subject_id': 1,
        'text': 'DNA stands for?',
        'option_a': 'Deoxyribonucleic Acid',
        'option_b': 'Diribonucleic Acid',
        'option_c': 'Deoxyribose Acid',
        'option_d': 'None',
        'correct_index': 0,
      },
      {
        'subject_id': 1,
        'text': 'Which organ produces insulin?',
        'option_a': 'Liver',
        'option_b': 'Kidney',
        'option_c': 'Pancreas',
        'option_d': 'Spleen',
        'correct_index': 2,
      },
      {
        'subject_id': 1,
        'text': 'How many bones are in the adult human body?',
        'option_a': '196',
        'option_b': '206',
        'option_c': '216',
        'option_d': '226',
        'correct_index': 1,
      },

      // Mathematics (subject_id = 2)
      {
        'subject_id': 2,
        'text': 'What is the value of π (pi) approximately?',
        'option_a': '3.14',
        'option_b': '2.71',
        'option_c': '1.61',
        'option_d': '1.41',
        'correct_index': 0,
      },
      {
        'subject_id': 2,
        'text': 'What is √144?',
        'option_a': '11',
        'option_b': '12',
        'option_c': '13',
        'option_d': '14',
        'correct_index': 1,
      },
      {
        'subject_id': 2,
        'text': 'How many sides does a hexagon have?',
        'option_a': '5',
        'option_b': '7',
        'option_c': '8',
        'option_d': '6',
        'correct_index': 3,
      },
      {
        'subject_id': 2,
        'text': '15% of 200 is?',
        'option_a': '25',
        'option_b': '30',
        'option_c': '35',
        'option_d': '40',
        'correct_index': 1,
      },

      // Foreign Language (subject_id = 3)
      {
        'subject_id': 3,
        'text': 'What does "Bonjour" mean in English?',
        'option_a': 'Goodbye',
        'option_b': 'Hello',
        'option_c': 'Thank you',
        'option_d': 'Please',
        'correct_index': 1,
      },
      {
        'subject_id': 3,
        'text': 'How do you say "Thank you" in Spanish?',
        'option_a': 'Gracias',
        'option_b': 'Hola',
        'option_c': 'Adios',
        'option_d': 'Por favor',
        'correct_index': 0,
      },
      {
        'subject_id': 3,
        'text': '"Arigatou" is thank you in which language?',
        'option_a': 'Chinese',
        'option_b': 'Korean',
        'option_c': 'Japanese',
        'option_d': 'Thai',
        'correct_index': 2,
      },

      // History (subject_id = 4)
      {
        'subject_id': 4,
        'text': 'In what year did World War II end?',
        'option_a': '1943',
        'option_b': '1944',
        'option_c': '1945',
        'option_d': '1946',
        'correct_index': 2,
      },
      {
        'subject_id': 4,
        'text': 'Who was the first president of the United States?',
        'option_a': 'Lincoln',
        'option_b': 'Jefferson',
        'option_c': 'Washington',
        'option_d': 'Adams',
        'correct_index': 2,
      },
      {
        'subject_id': 4,
        'text':
            'The Great Wall of China was primarily built during which dynasty?',
        'option_a': 'Tang',
        'option_b': 'Ming',
        'option_c': 'Han',
        'option_d': 'Qin',
        'correct_index': 1,
      },
      {
        'subject_id': 4,
        'text': 'Who wrote the Declaration of Independence?',
        'option_a': 'George Washington',
        'option_b': 'Benjamin Franklin',
        'option_c': 'Thomas Jefferson',
        'option_d': 'John Adams',
        'correct_index': 2,
      },

      // Physics (subject_id = 5)
      {
        'subject_id': 5,
        'text': 'What is the speed of light (km/s)?',
        'option_a': '200,000',
        'option_b': '300,000',
        'option_c': '150,000',
        'option_d': '400,000',
        'correct_index': 1,
      },
      {
        'subject_id': 5,
        'text': 'Unit of electric current is?',
        'option_a': 'Volt',
        'option_b': 'Watt',
        'option_c': 'Ohm',
        'option_d': 'Ampere',
        'correct_index': 3,
      },
      {
        'subject_id': 5,
        'text': 'What is Newton\'s first law also known as?',
        'option_a': 'Law of Gravity',
        'option_b': 'Law of Inertia',
        'option_c': 'Law of Motion',
        'option_d': 'Law of Energy',
        'correct_index': 1,
      },
      {
        'subject_id': 5,
        'text': 'The SI unit of force is?',
        'option_a': 'Joule',
        'option_b': 'Pascal',
        'option_c': 'Newton',
        'option_d': 'Watt',
        'correct_index': 2,
      },

      // Chemistry (subject_id = 6)
      {
        'subject_id': 6,
        'text': 'What is the chemical symbol for water?',
        'option_a': 'WA',
        'option_b': 'H2O',
        'option_c': 'HO2',
        'option_d': 'OHH',
        'correct_index': 1,
      },
      {
        'subject_id': 6,
        'text': 'What is the atomic number of Carbon?',
        'option_a': '4',
        'option_b': '6',
        'option_c': '8',
        'option_d': '12',
        'correct_index': 1,
      },
      {
        'subject_id': 6,
        'text': 'Which gas is most abundant in Earth\'s atmosphere?',
        'option_a': 'Oxygen',
        'option_b': 'Carbon Dioxide',
        'option_c': 'Nitrogen',
        'option_d': 'Argon',
        'correct_index': 2,
      },
    ];

    for (final q in questions) {
      await db.insert(AppConstants.questionsTable, q);
    }
  }

  // ── Generic CRUD ──────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }
}
