import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/category.dart';

class CategoryDatabaseService {
  static const _databaseName = 'tasks.db';
  static const _databaseVersion = 1;
  static const _categoriesTable = 'categories';

  static final CategoryDatabaseService
  _instance = CategoryDatabaseService._internal();

  factory CategoryDatabaseService() {
    return _instance;
  }

  CategoryDatabaseService._internal();

  Database?
  _database;

  Future<
    Database
  >
  get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<
    Database
  >
  _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(
      databasesPath,
      _databaseName,
    );

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  Future<
    void
  >
  _createTables(
    Database db,
    int version,
  ) async {
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS $_categoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''',
    );

    // Insert default categories
    await db.insert(
      _categoriesTable,
      Category(
        name: 'Work',
      ).toMap(),
    );
    await db.insert(
      _categoriesTable,
      Category(
        name: 'Personal',
      ).toMap(),
    );
    await db.insert(
      _categoriesTable,
      Category(
        name: 'Shopping',
      ).toMap(),
    );
  }

  // Get all categories
  Future<
    List<
      Category
    >
  >
  getAllCategories() async {
    final db = await database;
    final maps = await db.query(
      _categoriesTable,
    );
    return List.generate(
      maps.length,
      (
        i,
      ) => Category.fromMap(
        maps[i],
      ),
    );
  }

  // Add new category
  Future<
    Category
  >
  addCategory(
    String name,
  ) async {
    final db = await database;
    final id = await db.insert(
      _categoriesTable,
      Category(
        name: name,
      ).toMap(),
    );
    return Category(
      id: id,
      name: name,
    );
  }

  // Update category
  Future<
    void
  >
  updateCategory(
    int id,
    String newName,
  ) async {
    final db = await database;
    await db.update(
      _categoriesTable,
      {
        'name': newName,
      },
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  // Delete category
  Future<
    void
  >
  deleteCategory(
    int id,
  ) async {
    final db = await database;
    await db.delete(
      _categoriesTable,
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  // Close database
  Future<
    void
  >
  close() async {
    final db = _database;
    if (db !=
        null) {
      await db.close();
    }
  }
}
