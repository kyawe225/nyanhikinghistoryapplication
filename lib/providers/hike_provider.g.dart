// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hikehistoryRepository)
const hikehistoryRepositoryProvider = HikehistoryRepositoryProvider._();

final class HikehistoryRepositoryProvider
    extends
        $FunctionalProvider<
          HikehistoryRepository,
          HikehistoryRepository,
          HikehistoryRepository
        >
    with $Provider<HikehistoryRepository> {
  const HikehistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hikehistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hikehistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<HikehistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HikehistoryRepository create(Ref ref) {
    return hikehistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HikehistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HikehistoryRepository>(value),
    );
  }
}

String _$hikehistoryRepositoryHash() =>
    r'3e49a61a095338fc2214d2f590d4aeb68a3131bd';

@ProviderFor(Hikes)
const hikesProvider = HikesProvider._();

final class HikesProvider
    extends $AsyncNotifierProvider<Hikes, List<Hikehistory>> {
  const HikesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hikesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hikesHash();

  @$internal
  @override
  Hikes create() => Hikes();
}

String _$hikesHash() => r'5de4c7e634fdad4c96a220e92a2cb5a3403c1035';

abstract class _$Hikes extends $AsyncNotifier<List<Hikehistory>> {
  FutureOr<List<Hikehistory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Hikehistory>>, List<Hikehistory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Hikehistory>>, List<Hikehistory>>,
              AsyncValue<List<Hikehistory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
