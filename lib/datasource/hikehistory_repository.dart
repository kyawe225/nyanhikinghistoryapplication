import 'package:hiking_app_one/database/database.dart';
import 'package:hiking_app_one/database/database_table_column_names.dart';
import 'package:hiking_app_one/database/entities.dart';

class HikehistoryRepository {
  late final DatabaseHelper database;

  HikehistoryRepository(){
    database = DatabaseHelper();
  }

  // helper to escape single quotes for simple SQL interpolation
  String _esc(Object? v) {
    if (v == null) return '';
    return v.toString().replaceAll("'", "''");
  }

  List<Hikehistory> getAll(){
    return getAllPaged(null, null);
  }

  List<Hikehistory> getAllPaged(int? limit, int? offset) {
    final order = "ORDER BY ${HikehistoryTable.createdAt} DESC";
    final limitOffset = (limit != null) ? "LIMIT $limit${(offset != null) ? " OFFSET $offset" : ""}" : "";
    String selectQuery = """
      SELECT * FROM ${HikehistoryTable.tableName}
      $order
      $limitOffset;
    """;
    try {
      final result = database.select(selectQuery);
      return result.map((e) => Hikehistory.fromJson(e)).toList();
    } catch (e, st) {
      print('HikehistoryRepository.getAllPaged error: $e\n$st');
      return [];
    }
  }

  List<Hikehistory> getFavouritesPaged(int? limit, int? offset) {
    final where = "WHERE ${HikehistoryTable.isFavourite} = 1";
    final order = "ORDER BY ${HikehistoryTable.createdAt} DESC";
    final limitOffset = (limit != null) ? "LIMIT $limit${(offset != null) ? " OFFSET $offset" : ""}" : "";
    String selectQuery = """
      SELECT * FROM ${HikehistoryTable.tableName}
      $where
      $order
      $limitOffset;
    """;
    try {
      final result = database.select(selectQuery);
      return result.map((e) => Hikehistory.fromJson(e)).toList();
    } catch (e, st) {
      print('HikehistoryRepository.getFavouritesPaged error: $e\n$st');
      return [];
    }
  }

  Hikehistory? getDetail(String id){
    if (id.isEmpty) return null;
    String selectQuery = """
      SELECT * FROM ${HikehistoryTable.tableName}
      WHERE ${HikehistoryTable.id} = '${_esc(id)}';
    """;
    try {
      final result = database.select(selectQuery);
      if (result.isNotEmpty) {
        return Hikehistory.fromJson(result.first);
      }
      return null;
    } catch (e, st) {
      print('HikehistoryRepository.getDetail error: $e\n$st');
      return null;
    }
  }

  bool create(Hikehistory hikehistory){
    String insertQuery = """
      INSERT INTO ${HikehistoryTable.tableName} (
        ${HikehistoryTable.id}, ${HikehistoryTable.name}, ${HikehistoryTable.location}, ${HikehistoryTable.hikedDate},
        ${HikehistoryTable.parkingAvailable}, ${HikehistoryTable.lengthOfHike}, ${HikehistoryTable.difficultyLevel},
        ${HikehistoryTable.description}, ${HikehistoryTable.freeParking}, ${HikehistoryTable.isFavourite},
        ${HikehistoryTable.createdAt}
      ) VALUES (
        '${_esc(hikehistory.id)}', '${_esc(hikehistory.name)}', '${_esc(hikehistory.location)}',
        '${_esc(hikehistory.hikedDate.toIso8601String())}', '${_esc(hikehistory.parkingAvailable ? 'Yes' : 'No')}',
        ${hikehistory.lengthOfHike}, '${_esc(hikehistory.difficultyLevel)}', '${_esc(hikehistory.description)}',
        ${hikehistory.freeParking ? 1 : 0}, ${hikehistory.isFavourite ? 1 : 0},
        '${_esc(hikehistory.createdAt.toIso8601String())}'
      );
    """;
    try {
      database.execute(insertQuery);
      return true;
    } catch (e, st) {
      print('HikehistoryRepository.create error: $e\n$st');
      return false;
    }
  }

  bool update(String id, Hikehistory hikehistory){
    if (id.isEmpty) return false;
    String updateQuery = """
      UPDATE ${HikehistoryTable.tableName}
      SET
        ${HikehistoryTable.name} = '${_esc(hikehistory.name)}',
        ${HikehistoryTable.location} = '${_esc(hikehistory.location)}',
        ${HikehistoryTable.hikedDate} = '${_esc(hikehistory.hikedDate.toIso8601String())}',
        ${HikehistoryTable.parkingAvailable} = '${_esc(hikehistory.parkingAvailable ? 'Yes' : 'No')}',
        ${HikehistoryTable.lengthOfHike} = ${hikehistory.lengthOfHike},
        ${HikehistoryTable.difficultyLevel} = '${_esc(hikehistory.difficultyLevel)}',
        ${HikehistoryTable.description} = '${_esc(hikehistory.description)}',
        ${HikehistoryTable.freeParking} = ${hikehistory.freeParking ? 1 : 0},
        ${HikehistoryTable.isFavourite} = ${hikehistory.isFavourite ? 1 : 0}
      WHERE ${HikehistoryTable.id} = '${_esc(id)}';
    """;
    try {
      database.execute(updateQuery);
      return true;
    } catch (e, st) {
      print('HikehistoryRepository.update error: $e\n$st');
      return false;
    }
  }

  bool delete(String id){
    if (id.isEmpty) return false;
    String deleteQuery = """
      DELETE FROM ${HikehistoryTable.tableName}
      WHERE ${HikehistoryTable.id} = '${_esc(id)}';
    """;
    try {
      database.execute(deleteQuery);
      return true;
    } catch (e, st) {
      print('HikehistoryRepository.delete error: $e\n$st');
      return false;
    }
  }
  
  bool reset(){
    // TRUNCATE is not supported in SQLite; use DELETE instead.
    String resetQuery = """
      DELETE FROM ${HikehistoryTable.tableName};
    """;
    try {
      database.execute(resetQuery);
      return true;
    } catch (e, st) {
      print('HikehistoryRepository.reset error: $e\n$st');
      return false;
    }
  }

  bool toggleFavourite(String id, bool fav) {
    if (id.isEmpty) return false;
    final val = fav ? 1 : 0;
    String updateQuery = """
      UPDATE ${HikehistoryTable.tableName}
      SET ${HikehistoryTable.isFavourite} = $val
      WHERE ${HikehistoryTable.id} = '${_esc(id)}';
    """;
    try {
      database.execute(updateQuery);
      return true;
    } catch (e, st) {
      print('HikehistoryRepository.toggleFavourite error: $e\n$st');
      return false;
    }
  }
}