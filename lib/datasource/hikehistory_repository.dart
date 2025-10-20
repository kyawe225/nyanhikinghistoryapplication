import 'package:hiking_app_one/database/database.dart';
import 'package:hiking_app_one/database/database_table_column_names.dart';
import 'package:hiking_app_one/database/entities.dart';

class HikehistoryRepository {
  late final DatabaseHelper database;

  HikehistoryRepository(){
    database = DatabaseHelper();
  }

  getAll(){
    String selectQuery = """
      SELECT * FROM hiking_history
      ORDER BY ${HikehistoryTable.createdAt} DESC;
    """;
    final result = database.select(selectQuery);
    return result.map((e) => Hikehistory.fromJson(e)).toList();
  }

  getDetail(String id){
    String selectQuery = """
      SELECT * FROM hiking_history
      WHERE ${HikehistoryTable.id} = '$id';
    """;
    final result = database.select(selectQuery);
    if (result.isNotEmpty) {
      return Hikehistory.fromJson(result.first);
    }
    return null;
  }

  bool create(Hikehistory hikehistory){
    String insertQuery = """
      INSERT INTO hiking_history (
        ${HikehistoryTable.id}, ${HikehistoryTable.name}, ${HikehistoryTable.location}, ${HikehistoryTable.hikedDate},
        ${HikehistoryTable.parkingAvailable}, ${HikehistoryTable.lengthOfHike}, ${HikehistoryTable.difficultyLevel},
        ${HikehistoryTable.description}, ${HikehistoryTable.freeParking}, ${HikehistoryTable.isFavourite},
        ${HikehistoryTable.createdAt}
      ) VALUES (
        '${hikehistory.id}', '${hikehistory.name}', '${hikehistory.location}',
        '${hikehistory.hikedDate.toIso8601String()}', '${hikehistory.parkingAvailable ? 'Yes' : 'No'}',
        ${hikehistory.lengthOfHike}, '${hikehistory.difficultyLevel}', '${hikehistory.description}',
        ${hikehistory.freeParking ? 1 : 0}, ${hikehistory.isFavourite ? 1 : 0},
        '${hikehistory.createdAt.toIso8601String()}'
      );
    """;
    database.execute(insertQuery);
    return true;
  }

  update(String id, Hikehistory hikehistory){
    String updateQuery = """
      UPDATE hiking_history
      SET
        ${HikehistoryTable.name} = '${hikehistory.name}',
        ${HikehistoryTable.location} = '${hikehistory.location}',
        ${HikehistoryTable.hikedDate} = '${hikehistory.hikedDate.toIso8601String()}',
        ${HikehistoryTable.parkingAvailable} = '${hikehistory.parkingAvailable ? 'Yes' : 'No'}',
        ${HikehistoryTable.lengthOfHike} = ${hikehistory.lengthOfHike},
        ${HikehistoryTable.difficultyLevel} = '${hikehistory.difficultyLevel}',
        ${HikehistoryTable.description} = '${hikehistory.description}',
        ${HikehistoryTable.freeParking} = ${hikehistory.freeParking ? 1 : 0},
        ${HikehistoryTable.isFavourite} = ${hikehistory.isFavourite ? 1 : 0}
      WHERE ${HikehistoryTable.id} = '$id';
    """;
    database.execute(updateQuery);
    return true;
  }

  bool delete(String id){
    String deleteQuery = """
      DELETE FROM hiking_history
      WHERE ${HikehistoryTable.id} = '$id';
    """;
    database.execute(deleteQuery);
    return true;
  }
  
  bool reset(){
    String resetQuery = """
      TRUNCATE TABLE hiking_history;
    """;
    database.execute(resetQuery);
    return true;
  }

}