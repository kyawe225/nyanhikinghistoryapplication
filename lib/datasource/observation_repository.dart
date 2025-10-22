import 'package:hiking_app_one/database/database.dart';
import 'package:hiking_app_one/database/database_table_column_names.dart';
import 'package:hiking_app_one/database/entities.dart';

class ObservationRepository {
  late final DatabaseHelper database;

  ObservationRepository(){
    database = DatabaseHelper();
  }

  // Helper to escape single quotes for simple SQL string interpolation
  String _esc(Object? v) {
    if (v == null) return '';
    final s = v.toString();
    return s.replaceAll("'", "''");
  }

  List<Observation> getObservationsForHike(String hikingHistoryId) {
    // keep original behaviour (no paging) for callers that expect full list
    return getObservationsForHikePaged(hikingHistoryId, null, null);
  }

  // New: paginated fetch. If limit is null, no LIMIT clause applied.
  List<Observation> getObservationsForHikePaged(String hikingHistoryId, int? limit, int? offset) {
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
      final result = database.select(selectQuery);
      // result elements are mapped to Observation.fromJson as existing code expected
      return result.map((e) => Observation.fromJson(e)).toList();
    } catch (e, st) {
      print('ObservationRepository.getObservationsForHikePaged error: $e\n$st');
      return [];
    }
  }

  bool create(Observation observation) {
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
      database.execute(insertQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.create error: $e\n$st');
      return false;
    }
  }

  bool update(String id, Observation observation) {
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
      database.execute(updateQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.update error: $e\n$st');
      return false;
    }
  }

  bool delete(String id) {
    if (id.isEmpty) return false;
    String deleteQuery = """
      DELETE FROM ${ObservationTable.tableName}
      WHERE ${ObservationTable.id} = '${_esc(id)}';
    """;
    try {
      database.execute(deleteQuery);
      return true;
    } catch (e, st) {
      print('ObservationRepository.delete error: $e\n$st');
      return false;
    }
  }
}
