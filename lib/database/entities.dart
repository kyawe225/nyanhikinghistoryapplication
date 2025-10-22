// Top-level helpers used by the entity classes
import 'package:hiking_app_one/database/database_table_column_names.dart';

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes' || s == 'y';
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  final parsed = double.tryParse(v.toString());
  return parsed ?? 0.0;
}

DateTime _toDateTime(dynamic v, {bool isUtc = true}) {
  if (v == null) return isUtc ? DateTime.now().toUtc() : DateTime.now();
  if (v is DateTime) return isUtc ? v.toUtc() : v;
  if (v is int) return isUtc ? DateTime.fromMillisecondsSinceEpoch(v).toUtc() : DateTime.fromMillisecondsSinceEpoch(v);
  final s = v.toString();
  try {
    return isUtc ? DateTime.parse(s).toUtc() : DateTime.parse(s);
  } catch (_) {
    final millis = int.tryParse(s);
    if (millis != null) return isUtc ? DateTime.fromMillisecondsSinceEpoch(millis).toUtc() : DateTime.fromMillisecondsSinceEpoch(millis);
  }
  return isUtc ? DateTime.now().toUtc() : DateTime.now();
}

String _toStringSafe(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

class Hikehistory {
  String id;
  String name;
  String location;
  DateTime hikedDate;
  bool parkingAvailable;
  double lengthOfHike;
  String difficultyLevel;
  String description;
  bool freeParking;
  bool isFavourite;
  DateTime createdAt = DateTime.now().toUtc();

  Hikehistory({
    required this.id,
    required this.name,
    required this.location,
    required this.hikedDate,
    required this.parkingAvailable,
    required this.lengthOfHike,
    required this.difficultyLevel,
    required this.description,
    required this.freeParking,
    required this.isFavourite,
  });

  Hikehistory.fromJson(Map<String, dynamic> json)
      : id = _toStringSafe(_pick(json, ['id'])),
        name = _toStringSafe(_pick(json, ['name'])),
        location = _toStringSafe(_pick(json, ['location'])),
        hikedDate = _toDateTime(_pick(json, ['hikedDate', HikehistoryTable.hikedDate]),isUtc:false),
        parkingAvailable = _toBool(_pick(json, ['parkingAvailable', HikehistoryTable.parkingAvailable])),
        lengthOfHike = _toDouble(_pick(json, ['lengthOfHike', HikehistoryTable.lengthOfHike])),
        difficultyLevel = _toStringSafe(_pick(json, ['difficultyLevel', HikehistoryTable.difficultyLevel])),
        description = _toStringSafe(_pick(json, ['description'])),
        freeParking = _toBool(_pick(json, ['freeParking', HikehistoryTable.freeParking])),
        isFavourite = _toBool(_pick(json, ['isFavourite', HikehistoryTable.isFavourite])),
        createdAt = _toDateTime(_pick(json, ['createdAt', HikehistoryTable.createdAt]));
}

class Observation {
  String id;
  String hikingHistoryId;
  DateTime observationDate;
  String additionalComments;
  String observation; // contains text or path depending on observationType
  String observationType;
  DateTime createdAt = DateTime.now().toUtc();

  Observation({
    required this.id,
    required this.hikingHistoryId,
    required this.observationDate,
    required this.additionalComments,
    required this.observation,
    required this.observationType,
  });

  Observation.fromJson(Map<String, dynamic> json)
      : id = _toStringSafe(_pick(json, ['id'])),
        hikingHistoryId = _toStringSafe(_pick(json, ['hikingHistoryId', ObservationTable.hikingHistoryId])),
        observationDate = _toDateTime(_pick(json, ['observationDate', ObservationTable.observationDate]), isUtc: false),
        additionalComments = _toStringSafe(_pick(json, ['additionalComments', ObservationTable.additionalComments])),
        observation = (() {
          final path = _toStringSafe(_pick(json, ['observationPath', ObservationTable.observationPath]));
          if (path.isNotEmpty) return path;
          final text = _toStringSafe(_pick(json, ['observationText', ObservationTable.observationText, 'observation']));
          return text;
        })(),
        observationType = _toStringSafe(_pick(json, ['observationType', ObservationTable.observationType])),
        createdAt = _toDateTime(_pick(json, ['createdAt', ObservationTable.createdAt]));
}
