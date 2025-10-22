import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'database_config.dart';

class DatabaseHelper {
  late Database _db;


  DatabaseHelper(Database database) {
    _db= database;
  }

  static Future<Database> init() async {
    Database db;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/${Configs.databaseConnectionString}';
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    db = sqlite3.open(path);
    return db;
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
