import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_list_sql_lite/Models/todo.dart';

class DatabaseHelper {

  factory DatabaseHelper() {
		_databaseHelper ??= DatabaseHelper._createInstance();
		return _databaseHelper;
	}

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  static DatabaseHelper _databaseHelper;
  static Database _database;

  static const String todoTable = 'todo_table';
	static const String colId = 'id';
	static const String colTitle = 'title';
	static const String colDescription = 'description';
	static const String colDate = 'date';

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {

    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path + 'todos.db';
    final Database todosDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  Future<void> _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
				'$colDescription TEXT, $colDate TEXT)');
	}

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTodoMapList() async {
		final Database db = await database;

    //var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');
		return await db.query(todoTable, orderBy: '$colTitle ASC');
	}

  Future<List<Todo>> getTodoList() async {
    final List<Map<String, dynamic>> todoMapList = await getTodoMapList();
    final int count = todoMapList.length;

    final List<Todo> todoList = <Todo>[];
    
    for (int i = 0; i < count; i++) {
			todoList.add(Todo.fromMapObject(todoMapList[i]));
		}

    return todoList;

  }

  // Insert Operation: Insert a todo object to database
	Future<int> insertTodo(Todo todo) async {
		final Database db = await database;

		final int id = await db.insert(todoTable, todo.toMap());
		return id;
  }
  
  // Delete Operation: Delete a todo object from database
	Future<int> deleteTodo(int id) async {
		final Database db = await database;

		final int deleteCount = await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
		return deleteCount;
	}

	
}