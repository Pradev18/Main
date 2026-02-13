import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final TABLE_DATA = "data";
  static final COLUMN_DATA_SNO = "s_no";
  static final COLUMN_DATA_TITLE = "title";
  static final COLUMN_DATA_DESC = "desc";
  static final COLUMN_DATA_TIME = "timestamp";

  DBHelper._();

  static final DBHelper instance = DBHelper._();

  Database? _db;

  Future<Database> getDb() async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await openDb();
      return _db!;
    }
  }

  Future<Database> openDb() async {
    Directory appdir = await getApplicationDocumentsDirectory();

    final dbPath = join(appdir.path, "data.db");

    return await openDatabase(dbPath, onCreate: (db, version) async {
      await db.execute(
          "create table $TABLE_DATA ( $COLUMN_DATA_SNO integer primary key autoincrement, $COLUMN_DATA_TITLE text, $COLUMN_DATA_DESC text, $COLUMN_DATA_TIME integer)");
    }, version: 1);
  }

  Future<bool> addData(
      {required String nTitle,
      required String nDesc,
      required int nTime}) async {
    var db = await getDb();

    int rowsAffected = await db.insert(TABLE_DATA, {
      COLUMN_DATA_TITLE: nTitle,
      COLUMN_DATA_DESC: nDesc,
      COLUMN_DATA_TIME: nTime,
    });

    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    var db = await getDb();

    List<Map<String, dynamic>> mData =
        await db.query(TABLE_DATA, orderBy: "$COLUMN_DATA_SNO DESC");

    return mData;
  }

  Future<bool> delete({required int sno}) async {
    var db = await getDb();

    int rowseffcted = await db
        .delete(TABLE_DATA, where: "$COLUMN_DATA_SNO = ?", whereArgs: ["$sno"]);

    return rowseffcted > 0;
  }

  Future<bool> clearALlnotification() async {
    var db = await getDb();
    int rowseffcted = await db.delete(TABLE_DATA);
    return rowseffcted > 0;
  }
}
