import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bible_reading.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNull = 'TEXT';
    const intTypeNull = 'INTEGER';

    // bible_readings 테이블
    await db.execute('''
      CREATE TABLE bible_readings (
        id $idType,
        month $intType,
        day $intType,
        youtube_url $textType,
        title $textType,
        chapter_info $textTypeNull,
        is_special INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(month, day)
      )
    ''');

    await db
        .execute('CREATE INDEX idx_month_day ON bible_readings(month, day)');

    // bible_books 테이블
    await db.execute('''
      CREATE TABLE bible_books (
        id $idType,
        book_number $intType UNIQUE,
        testament $textType,
        korean_name $textType,
        english_name $textTypeNull,
        youtube_url $textType,
        author $textTypeNull,
        chapters_count $intType,
        summary $textTypeNull,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('CREATE INDEX idx_testament ON bible_books(testament)');

    // reading_history 테이블
    await db.execute('''
      CREATE TABLE reading_history (
        id $idType,
        year $intType,
        month $intType,
        day $intType,
        is_completed INTEGER DEFAULT 0,
        completed_at $textTypeNull,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(year, month, day)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_year_month_day ON reading_history(year, month, day)');

    // user_notes 테이블
    await db.execute('''
      CREATE TABLE user_notes (
        id $idType,
        year $intType,
        month $intType,
        day $intType,
        verse_reference $textTypeNull,
        note_content $textType,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_year_month_day_note ON user_notes(year, month, day)');

    // book_notes 테이블
    await db.execute('''
      CREATE TABLE book_notes (
        id $idType,
        book_id $intType,
        note_content $textType,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(book_id),
        FOREIGN KEY (book_id) REFERENCES bible_books(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_book_id ON book_notes(book_id)');

    // app_settings 테이블
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value $textTypeNull,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 초기 설정값
    await db.insert('app_settings', {
      'key': 'target_year',
      'value': DateTime.now().year.toString(),
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
