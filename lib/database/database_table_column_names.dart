
class HikehistoryTable{
  static const String tableName = 'hike_history';
  static const String id = 'id';
  static const String name = 'name';
  static const String location = 'location';
  static const String hikedDate = 'hiked_date';
  static const String parkingAvailable = 'parking_available';
  static const String lengthOfHike = 'length_of_hike';
  static const String difficultyLevel = 'difficulty_level';
  static const String description = 'description';
  static const String freeParking = 'free_parking';
  static const String isFavourite = 'is_favourite';
  static const String createdAt = 'created_at';
}

class ObservationTable{
  static const String tableName = 'observations';
  static const String id = 'id';
  static const String hikeHistoryId = 'hiking_history_id';
  static const String observationDate = 'observation_date';
  static const String additionalComments = 'additional_comments';
  static const String observation = 'observation';
  static const String observationType = 'observation_type';
  static const String createdAt = 'created_at';
}