import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import './databaseConfig.dart';

class DatabaseHelper{
  late Database _db;

  DatabaseHelper() {
    _db = sqlite3.open(Configs.databaseConnectionString);
  }

  void execute(String sql) {
    _db.execute(sql);
  }

  ResultSet select(String sql) {
    return _db.select(sql);
  }

  void close() {
    _db.dispose();
  }
}
