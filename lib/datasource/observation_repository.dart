import 'package:hiking_app_one/database/database.dart';
import 'package:hiking_app_one/database/database_table_column_names.dart';
import 'package:hiking_app_one/database/entities.dart';

class ObservationRepository {
  late DatabaseHelper? database;

  ObservationRepository(){
    database = null;
  }
  Future getDatabaseHelper() async{
    if(database == null){
      final db = await DatabaseHelper.init();
      database = DatabaseHelper(db);
    }
    return true;
  }

  // Helper to escape single quotes for simple SQL string interpolation
  String _esc(Object? v) {
    if (v == null) return '';
    final s = v.toString();
    return s.replaceAll("'", "''");
  }

  Future<List<Observation>> getObservationsForHike(String hikingHistoryId) async {
    // keep original behaviour (no paging) for callers that expect full list
    await getDatabaseHelper();
    return getObservationsForHikePaged(hikingHistoryId, null, null);
  }

  // New: paginated fetch. If limit is null, no LIMIT clause applied.
  Future<List<Observation>> getObservationsForHikePaged(String hikingHistoryId, int? limit, int? offset) async {
    await getDatabaseHelper();
    if (hikingHistoryId.isEmpty) return [];
    final where = "WHERE ${ObservationTable.hikingHistoryId} = '${_esc(hikingHistoryId)}'";
    final order = "ORDER BY ${ObservationTable.observationDate} DESC";
    final limitOffset = (limit != null) ? "LIMIT $limit${(offset != null) ? " OFFSET $offset" : ""}" : "";
    String selectQuery = """
      SELECT * FROM ${ObservationTable.tableName}
      $where
      $order
      $limitOffset;
    """;
    try {
      final result = database!.select(selectQuery);
      // result elements are mapped to Observation.fromJson as existing code expected
      return result.map((e) => Observation.fromJson(e)).toList();
    } catch (e, st) {
      print('ObservationRepository.getObservationsForHikePaged error: $e\n$st');
      return [];
    }
  }

  Future<bool> create(Observation observation) async {
    await getDatabaseHelper();
    // Decide which column to populate
    final textVal = (observation.observationType.toLowerCase() == 'image') ? '' : observation.observation;
    final pathVal = (observation.observationType.toLowerCase() == 'image') ? observation.observation : '';

    String insertQuery = """
      INSERT INTO ${ObservationTable.tableName} (
        ${ObservationTable.id}, ${ObservationTable.hikingHistoryId}, ${ObservationTable.observationDate},
        ${ObservationTable.additionalComments}, ${ObservationTable.observationText}, ${ObservationTable.observationPath}, ${ObservationTable.observationType},
        ${ObservationTable.createdAt}
      ) VALUES (
        '${_esc(observation.id)}', '${_esc(observation.hikingHistoryId)}', '${_esc(observation.observationDate.toIso8601String())}',
        '${_esc(observation.additionalComments)}', '${_esc(textVal)}', '${_esc(pathVal)}', '${_esc(observation.observationType)}',
        '${_esc(observation.createdAt.toIso8601String())}'
      );
    """;
    try {
      database!.execute(insertQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.create error: $e\n$st');
      return false;
    }
  }

  Future<bool> update(String id, Observation observation) async {
    await getDatabaseHelper();
    final textVal = (observation.observationType.toLowerCase() == 'image') ? '' : observation.observation;
    final pathVal = (observation.observationType.toLowerCase() == 'image') ? observation.observation : '';

    String updateQuery = """
      UPDATE ${ObservationTable.tableName}
      SET
        ${ObservationTable.hikingHistoryId} = '${_esc(observation.hikingHistoryId)}',
        ${ObservationTable.observationDate} = '${_esc(observation.observationDate.toIso8601String())}',
        ${ObservationTable.additionalComments} = '${_esc(observation.additionalComments)}',
        ${ObservationTable.observationText} = '${_esc(textVal)}',
        ${ObservationTable.observationPath} = '${_esc(pathVal)}',
        ${ObservationTable.observationType} = '${_esc(observation.observationType)}'
      WHERE ${ObservationTable.id} = '${_esc(id)}';
    """;
    try {
      database!.execute(updateQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.update error: $e\n$st');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    await getDatabaseHelper();
    if (id.isEmpty) return false;
    String deleteQuery = """
      DELETE FROM ${ObservationTable.tableName}
      WHERE ${ObservationTable.id} = '${_esc(id)}';
    """;
    try {
      database!.execute(deleteQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.delete error: $e\n$st');
      return false;
    }
  }
}
