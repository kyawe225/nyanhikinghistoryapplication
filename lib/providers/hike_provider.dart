import 'package:hiking_app_one/database/entities.dart';
import 'package:hiking_app_one/datasource/hikehistory_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hike_provider.g.dart';

@riverpod
HikehistoryRepository hikehistoryRepository(Ref ref) {
  return HikehistoryRepository();
}

@riverpod
class Hikes extends _$Hikes {
  // paging state
  final int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;
  final List<Hikehistory> _items = [];

  @override
  Future<List<Hikehistory>> build() async {
    // initial load
    _offset = 0;
    _hasMore = true;
    _items.clear();
    return await _loadInitial();
  }

  Future<List<Hikehistory>> _loadInitial() async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    final page = await repository.getAllPaged(_pageSize, _offset);
    _items.addAll(page);
    _offset += page.length;
    if (page.length < _pageSize) _hasMore = false;
    return List.unmodifiable(_items);
  }

  // Public method to load next page; safe to call multiple times.
  Future<void> loadMore() async {
    if (!_hasMore) return;
    state = const AsyncValue.loading();
    final repository = ref.read(hikehistoryRepositoryProvider);
    try {
      final page = await repository.getAllPaged(_pageSize, _offset);
      if (page.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(page);
        _offset += page.length;
        if (page.length < _pageSize) _hasMore = false;
      }
      state = AsyncValue.data(List.unmodifiable(_items));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<Hikehistory> _loadCached() => List.unmodifiable(_items);

  List<Hikehistory> _loadHikes() {
    // for compatibility; returns cached items
    return _loadCached();
  }

  Future<void> addHike(Hikehistory hike) async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    repository.create(hike);
    // refresh from start
    state = await AsyncValue.guard(() => Future.value(_reloadAll()));
  }

  Future<void> updateHike(Hikehistory hike) async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    repository.update(hike.id, hike);
    state = await AsyncValue.guard(() => Future.value(_reloadAll()));
  }

  Future<void> deleteHike(String id) async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    repository.delete(id);
    state = await AsyncValue.guard(() => Future.value(_reloadAll()));
  }

  Future<void> resetHikes() async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    repository.reset();
    state = await AsyncValue.guard(() => Future.value(_reloadAll()));
  }

  Future<List<Hikehistory>> _reloadAll() async {
    _offset = 0;
    _hasMore = true;
    _items.clear();
    final repository = ref.read(hikehistoryRepositoryProvider);
    final firstPage = await repository.getAllPaged(_pageSize, _offset);
    _items.addAll(firstPage);
    _offset += firstPage.length;
    if (firstPage.length < _pageSize) _hasMore = false;
    return List.unmodifiable(_items);
  }

  // New: toggle favourite and update local cache
  Future<void> toggleFavourite(String id, bool fav) async {
    final repository = ref.read(hikehistoryRepositoryProvider);
    final ok = await repository.toggleFavourite(id, fav);
    if (!ok) return;
    // update local cache if present
    final idx = _items.indexWhere((h) => h.id == id);
    if (idx != -1) {
      final updated = Hikehistory(
        id: _items[idx].id,
        name: _items[idx].name,
        location: _items[idx].location,
        hikedDate: _items[idx].hikedDate,
        parkingAvailable: _items[idx].parkingAvailable,
        lengthOfHike: _items[idx].lengthOfHike,
        difficultyLevel: _items[idx].difficultyLevel,
        description: _items[idx].description,
        freeParking: _items[idx].freeParking,
        isFavourite: fav,
      );
      try { updated.createdAt = _items[idx].createdAt; } catch (_) {}
      _items[idx] = updated;
      state = AsyncValue.data(List.unmodifiable(_items));
    } else {
      // if not in current cache, optionally reload initial page
      state = await AsyncValue.guard(() => Future.value(_reloadAll()));
    }
  }
}