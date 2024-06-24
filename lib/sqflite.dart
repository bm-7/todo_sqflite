import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class SqfliteHelper {
  static Future<void> CreateTable(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  title TEXT,
  description TEXT,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "study.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await CreateTable(database);
      },
    );
  }

  static Future createiteams(String title, String description) async {
    final db = await SqfliteHelper.db();
    final data = {"title": title, "description": description};
    final id = await db.insert("items", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getiteams() async {
    final db = await SqfliteHelper.db();
    return db.query("items", orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getiteam(int id) async {
    final db = await SqfliteHelper.db();
    return db.query("items",
        limit: 1, orderBy: "id", whereArgs: [id], where: "id==?");
  }

  static Future Update(int id, String title, String description) async {
    final db = await SqfliteHelper.db();

    final data = {
      "title": title,
      "description": description,
      "createdAt": DateTime.now().toString()
    };

    final res = await db.update("items", data, where: "id==?", whereArgs: [id]);
    return res;
  }

  static Future deleteitem(int id) async {
    final db = await SqfliteHelper.db();
    try {
      await db.delete("items", where: "id==?", whereArgs: [id]);
    } catch (e) {
      debugPrint(">>>>>>>>>>>>>>>>>>$e");
    }
  }
}
