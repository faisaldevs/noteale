import 'package:noteale_v2/model/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


/// Database helper class for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Updated version for schema changes
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create notes table
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
    const intType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        tags $nullableTextType,
        createdAt $textType,
        updatedAt $textType,
        isPinned $intType,
        color $nullableTextType,
        isFavorite $intType,
        category $nullableTextType,
        attachments $nullableTextType
      )
    ''');
  }

  /// Upgrade database schema
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute('ALTER TABLE notes ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE notes ADD COLUMN color TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE notes ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN attachments TEXT');
    }
  }

  /// Insert a new note
  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  /// Get a single note by id
  Future<Note?> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  /// Get all notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = 'isPinned DESC, updatedAt DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  /// Get favorite notes
  Future<List<Note>> getFavoriteNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }

  /// Get notes by category
  Future<List<Note>> getNotesByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updatedAt DESC',
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }

  /// Get all categories
  Future<List<String>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM notes WHERE category IS NOT NULL ORDER BY category',
    );
    return result
        .map((row) => row['category'] as String)
        .where((cat) => cat.isNotEmpty)
        .toList();
  }

  /// Update an existing note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await instance.database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    final favoriteResult = await db.rawQuery('SELECT COUNT(*) as count FROM notes WHERE isFavorite = 1');
    final pinnedResult = await db.rawQuery('SELECT COUNT(*) as count FROM notes WHERE isPinned = 1');
    
    return {
      'total': totalResult.first['count'] as int,
      'favorites': favoriteResult.first['count'] as int,
      'pinned': pinnedResult.first['count'] as int,
    };
  }

  /// Close database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}