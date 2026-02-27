import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocalDb {
  static Database? _database;

  /// Get database instance
  static Future<Database> getDb() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  /// Create table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        name TEXT,
        title TEXT,
        description TEXT,
        status TEXT,
        dueDate TEXT,
        userId TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN synced INTEGER DEFAULT 0');
    }
  }

  /// Insert single task offline or general use
  static Future<void> insertTask(Task task, {bool fromApi = false}) async {
    final db = await getDb();
    final map = task.toMap();
    map['synced'] = fromApi ? 1 : 0;

    await db.insert('tasks', map, conflictAlgorithm: ConflictAlgorithm.replace);

    print("Inserted task locally: ${task.title} id=${task.id}");
  }

  /// Get all tasks
  static Future<List<Task>> getTasks() async {
    final db = await getDb();
    final maps = await db.query('tasks', orderBy: 'dueDate ASC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Update task
  static Future<void> updateTask(Task task, {bool synced = true}) async {
    final db = await getDb();
    final map = task.toMap();
    map['synced'] = synced ? 1 : 0;

    await db.update('tasks', map, where: 'id = ?', whereArgs: [task.id]);
  }

  /// Delete task
  static Future<void> deleteTask(String id) async {
    final db = await getDb();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all tasks
  static Future<void> clearTasks() async {
    final db = await getDb();
    await db.delete('tasks');
  }

  /// Cache full API response (bulk insert) - preserves unsynced offline tasks
  static Future<void> cacheTasksFromApi(List<Task> tasks) async {
    final db = await getDb();
    final batch = db.batch();

    //  Only delete synced tasks, preserves offline unsynced ones
    batch.delete('tasks', where: 'synced = ?', whereArgs: [1]);

    for (final task in tasks) {
      final map = task.toMap();
      map['synced'] = 1;
      batch.insert('tasks', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Get unsynced tasks
  static Future<List<Task>> getUnsyncedTasks() async {
    final db = await getDb();
    final maps = await db.query('tasks', where: 'synced = ?', whereArgs: [0]);
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Sync offline tasks to API
  static Future<void> syncOfflineTasks(String baseUrl, String token) async {
    final unsynced = await getUnsyncedTasks();

    for (final task in unsynced) {
      try {
        final formattedDueDate = task.dueDate.contains('-')
            ? task.dueDate
            : DateTime.parse(task.dueDate).toIso8601String().split('T')[0];

        final response = await http.post(
          Uri.parse('$baseUrl/api/tasks'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': task.name,
            'title': task.title,
            'description': task.description,
            'status': task.status,
            'due_date': formattedDueDate,
          }),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);

          //  Handle both { data: {...} } and direct {...} response shapes
          final taskData = responseData['data'] ?? responseData;
          final serverTask = Task.fromMap(taskData);

          //  Remove old local task (has temp local ID)
          await deleteTask(task.id);

          //  Insert new task with real server ID
          await insertTask(serverTask, fromApi: true);

          print('Task synced: ${task.title}');
        } else {
          print('Failed to sync task: ${response.body}');
        }
      } catch (e) {
        print('Error syncing task ${task.title}: $e');
      }
    }
  }
}
