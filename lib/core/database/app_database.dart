
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitmind.db');

    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            fitness_goal TEXT NOT NULL,
            activity_level TEXT NOT NULL,
            available_minutes INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE daily_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            log_date TEXT NOT NULL UNIQUE,
            steps INTEGER DEFAULT 0,
            water_ml INTEGER DEFAULT 0,
            workout_minutes INTEGER DEFAULT 0,
            break_count INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_active INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE habit_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id INTEGER NOT NULL,
            log_date TEXT NOT NULL,
            is_completed INTEGER DEFAULT 0,
            UNIQUE(habit_id, log_date),
            FOREIGN KEY(habit_id)
              REFERENCES habits(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE mood_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            log_date TEXT NOT NULL UNIQUE,
            mood TEXT NOT NULL,
            energy_level INTEGER NOT NULL,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE focus_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_date TEXT NOT NULL,
            focus_minutes INTEGER NOT NULL,
            break_minutes INTEGER NOT NULL,
            completed INTEGER DEFAULT 0
          )
        ''');
      },
    );

    return _database!;
  }

  String get today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // USER PROFILE

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);

    return result.isEmpty ? null : result.first;
  }

  Future<void> saveProfile({
    required String name,
    required String goal,
    required String activityLevel,
    required int availableMinutes,
  }) async {
    final db = await database;

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'name': name,
        'fitness_goal': goal,
        'activity_level': activityLevel,
        'available_minutes': availableMinutes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // DAILY ACTIVITY

  Future<void> ensureTodayLog() async {
    final db = await database;

    await db.insert(
      'daily_logs',
      {'log_date': today},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<String, dynamic>> getTodayLog() async {
    await ensureTodayLog();

    final db = await database;
    final result = await db.query(
      'daily_logs',
      where: 'log_date = ?',
      whereArgs: [today],
    );

    return result.first;
  }

  Future<void> updateDailyActivity(
    String field,
    int amount,
  ) async {
    const allowedFields = [
      'steps',
      'water_ml',
      'workout_minutes',
      'break_count',
    ];

    if (!allowedFields.contains(field)) {
      throw ArgumentError('Invalid activity field');
    }

    await ensureTodayLog();

    final db = await database;

    await db.rawUpdate(
      'UPDATE daily_logs SET $field = $field + ? WHERE log_date = ?',
      [amount, today],
    );
  }

  // HABITS

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;

    return db.rawQuery('''
      SELECT habits.id, habits.name,
      COALESCE(habit_logs.is_completed, 0) AS is_completed
      FROM habits
      LEFT JOIN habit_logs
      ON habits.id = habit_logs.habit_id
      AND habit_logs.log_date = ?
      WHERE habits.is_active = 1
      ORDER BY habits.id DESC
    ''', [today]);
  }

  Future<void> addHabit(String name) async {
    final db = await database;

    await db.insert('habits', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> toggleHabit(int habitId, bool completed) async {
    final db = await database;

    await db.insert(
      'habit_logs',
      {
        'habit_id': habitId,
        'log_date': today,
        'is_completed': completed ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(int id) async {
    final db = await database;

    await db.update(
      'habits',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MOOD AND ENERGY

  Future<void> saveMood({
    required String mood,
    required int energy,
    String? note,
  }) async {
    final db = await database;

    await db.insert(
      'mood_entries',
      {
        'log_date': today,
        'mood': mood,
        'energy_level': energy,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // FOCUS SESSIONS

  Future<void> saveFocusSession({
    required int focusMinutes,
    required int breakMinutes,
  }) async {
    final db = await database;

    await db.insert('focus_sessions', {
      'session_date': today,
      'focus_minutes': focusMinutes,
      'break_minutes': breakMinutes,
      'completed': 1,
    });
  }

  // WEEKLY ANALYTICS

  Future<List<Map<String, dynamic>>> getWeeklyLogs() async {
    final db = await database;

    final startDate = DateTime.now().subtract(
      const Duration(days: 6),
    );

    final start = '${startDate.year}-'
        '${startDate.month.toString().padLeft(2, '0')}-'
        '${startDate.day.toString().padLeft(2, '0')}';

    return db.query(
      'daily_logs',
      where: 'log_date >= ?',
      whereArgs: [start],
      orderBy: 'log_date ASC',
    );
  }

  Future<int> getTotalFocusMinutes() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(focus_minutes) AS total FROM focus_sessions',
    );

    return (result.first['total'] as int?) ?? 0;
  }
}
