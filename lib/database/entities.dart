
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
  DateTime createdAt= DateTime.now().toUtc();

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
      : id = json['id'] as String,
        name = json['name'] as String,
        location = json['location'] as String,
        hikedDate = DateTime.parse(json['hikedDate'] as String),
        parkingAvailable = json['parkingAvailable'] as bool,
        lengthOfHike = json['lengthOfHike'] as double,
        difficultyLevel = json['difficultyLevel'] as String,
        description = json['description'] as String,
        freeParking = json['freeParking'] as bool,
        isFavourite = json['isFavourite'] as bool,
        createdAt = DateTime.parse(json['createdAt'] as String);
}

class Observation{
  String id;
  String hikingHistoryId;
  DateTime observationDate;
  String additionalComments;
  String observation;
  String observationType;
  DateTime createdAt = DateTime.now().toUtc();

  Observation({
    required this.id,
    required this.hikingHistoryId,
    required this.observationDate,
    required this.additionalComments,
    required this.observation,
    required this.observationType
  });

  Observation.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        hikingHistoryId = json['hikingHistoryId'] as String,
        observationDate = DateTime.parse(json['observationDate'] as String),
        additionalComments = json['additionalComments'] as String,
        observation = json['observation'] as String,
        observationType = json['observationType'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String);
}
