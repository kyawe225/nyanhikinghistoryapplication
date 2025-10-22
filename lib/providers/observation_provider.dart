import 'package:hiking_app_one/database/entities.dart';
import 'package:hiking_app_one/datasource/observation_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'observation_provider.g.dart';

@riverpod
ObservationRepository observationRepository(Ref ref) {
  return ObservationRepository();
}

@riverpod
class Observations extends _$Observations {
  @override
  Future<List<Observation>> build(String hikingHistoryId) {
    return Future.value(_loadObservations(hikingHistoryId));
  }

  Future<List<Observation>> _loadObservations(String hikingHistoryId) async {
    final repository = ref.read(observationRepositoryProvider);
    return await repository.getObservationsForHike(hikingHistoryId);
  }

  Future<void> addObservation(Observation observation) async {
    final repository = ref.read(observationRepositoryProvider);
    repository.create(observation);
    state = await AsyncValue.guard(() => Future.value(_loadObservations(observation.hikingHistoryId)));
  }

  Future<void> updateObservation(Observation observation) async {
    final repository = ref.read(observationRepositoryProvider);
    repository.update(observation.id, observation);
    state = await AsyncValue.guard(() => Future.value(_loadObservations(observation.hikingHistoryId)));
  }

  Future<void> deleteObservation(String id, String hikingHistoryId) async {
    final repository = ref.read(observationRepositoryProvider);
    repository.delete(id);
    state = await AsyncValue.guard(() => Future.value(_loadObservations(hikingHistoryId)));
  }
}
