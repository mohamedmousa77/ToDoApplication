import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/moduls/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('Not null db');
      return;
    } else {
      try {
        String _path = await getDatabasesPath() + 'task.db';
        _db = await openDatabase(_path, version: _version,
            onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE $_tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'title STRING,'
              'note TEXT,'
              'date STRING,'
              'startTime STRING,'
              'endTime STRING,'
              'remind INTEGER ,'
              'repeat STRING,'
              'color INTEGER,'
              'isCompleted INTEGER)');
        });
      } catch (e) {
        debugPrint ('Error Enable to Create table');
      }
    }
  }

  static Future<int> insert(Task? task) async {
    debugPrint('Insert function called! ');
    try {
      return await _db!.insert(_tableName, task!.toJson());
    } catch (e) {
      debugPrint('#### Here in Insert Function');
      return 900;
    }
  }

  static Future<int> delete(Task task) async {
    debugPrint('Delete function called!');
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteAll() async {
    debugPrint('Delete All function called!');
    return await _db!.delete(_tableName);
  }
  static Future<List<Map<String, dynamic>>> query() async {
    debugPrint('Query function called!');
    return await _db!.query(_tableName);
  }

  static Future<int> update(int id) async {
    debugPrint('Update function called!');
    return await _db!.rawUpdate('''
    UPDATE  $_tableName
    SET isCompleted = ? 
    WHERE id = ?
    ''', [1, id]);
  }
}
