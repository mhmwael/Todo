import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/task.dart';
import '../../models/task_priority.dart';

class TaskDatabaseService {
  static const _databaseName = 'tasks_v3.db';
  static const _databaseVersion = 1;
  static const _tasksTable = 'tasks';

  static final TaskDatabaseService _instance = TaskDatabaseService._internal();
  factory TaskDatabaseService() => _instance;
  TaskDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tasksTable (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            dueDate TEXT NOT NULL,
            priority TEXT NOT NULL,
            isCompleted INTEGER NOT NULL,
            category TEXT NOT NULL,
            isPinned INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query(_tasksTable);
    return maps.map((map) {
      return Task(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        dueDate: DateTime.parse(map['dueDate'] as String),
        priority: TaskPriority.values.firstWhere(
          (e) => e.toString().split('.').last == map['priority'],
        ),
        isCompleted: (map['isCompleted'] as int) == 1,
        category: map['category'] as String,
        isPinned: (map['isPinned'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> addTask(Task task) async {
    final db = await database;
    await db.insert(
      _tasksTable,
      {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'priority': task.priority.toString().split('.').last,
        'isCompleted': task.isCompleted ? 1 : 0,
        'category': task.category,
        'isPinned': task.isPinned ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      _tasksTable,
      {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'priority': task.priority.toString().split('.').last,
        'isCompleted': task.isCompleted ? 1 : 0,
        'category': task.category,
        'isPinned': task.isPinned ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(_tasksTable, where: 'id = ?', whereArgs: [id]);
  }
}
