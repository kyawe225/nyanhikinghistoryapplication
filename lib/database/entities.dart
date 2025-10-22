// Top-level helpers used by the entity classes
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
        hikedDate = _toDateTime(_pick(json, ['hikedDate', 'hiked_date']),isUtc:false),
        parkingAvailable = _toBool(_pick(json, ['parkingAvailable', 'parking_available'])),
        lengthOfHike = _toDouble(_pick(json, ['lengthOfHike', 'length_of_hike'])),
        difficultyLevel = _toStringSafe(_pick(json, ['difficultyLevel', 'difficulty_level'])),
        description = _toStringSafe(_pick(json, ['description'])),
        freeParking = _toBool(_pick(json, ['freeParking', 'free_parking'])),
        isFavourite = _toBool(_pick(json, ['isFavourite', 'is_favourite'])),
        createdAt = _toDateTime(_pick(json, ['createdAt', 'created_at']));
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
        hikingHistoryId = _toStringSafe(_pick(json, ['hikingHistoryId', 'hiking_history_id'])),
        observationDate = _toDateTime(_pick(json, ['observationDate', 'observation_date']), isUtc: false),
        additionalComments = _toStringSafe(_pick(json, ['additionalComments', 'additional_comments'])),

        // prefer path if present, otherwise use text field (keeps backwards compatibility)
        observation = (() {
          final path = _toStringSafe(_pick(json, ['observationPath', 'observation_path']));
          if (path.isNotEmpty) return path;
          final text = _toStringSafe(_pick(json, ['observationText', 'observation_text', 'observation']));
          return text;
        })(),

        observationType = _toStringSafe(_pick(json, ['observationType', 'observation_type'])),
        createdAt = _toDateTime(_pick(json, ['createdAt', 'created_at']));
}
