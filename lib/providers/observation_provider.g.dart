// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(observationRepository)
const observationRepositoryProvider = ObservationRepositoryProvider._();

final class ObservationRepositoryProvider
    extends
        $FunctionalProvider<
          ObservationRepository,
          ObservationRepository,
          ObservationRepository
        >
    with $Provider<ObservationRepository> {
  const ObservationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ObservationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ObservationRepository create(Ref ref) {
    return observationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ObservationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ObservationRepository>(value),
    );
  }
}

String _$observationRepositoryHash() =>
    r'ea7371ee974b1a7c995e9b0061f02ffc8bcc3430';

@ProviderFor(Observations)
const observationsProvider = ObservationsFamily._();

final class ObservationsProvider
    extends $AsyncNotifierProvider<Observations, List<Observation>> {
  const ObservationsProvider._({
    required ObservationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'observationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$observationsHash();

  @override
  String toString() {
    return r'observationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Observations create() => Observations();

  @override
  bool operator ==(Object other) {
    return other is ObservationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$observationsHash() => r'6b3f2347b7ba0aab9307d8e60ff8272c87e35440';

final class ObservationsFamily extends $Family
    with
        $ClassFamilyOverride<
          Observations,
          AsyncValue<List<Observation>>,
          List<Observation>,
          FutureOr<List<Observation>>,
          String
        > {
  const ObservationsFamily._()
    : super(
        retry: null,
        name: r'observationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ObservationsProvider call(String hikingHistoryId) =>
      ObservationsProvider._(argument: hikingHistoryId, from: this);

  @override
  String toString() => r'observationsProvider';
}

abstract class _$Observations extends $AsyncNotifier<List<Observation>> {
  late final _$args = ref.$arg as String;
  String get hikingHistoryId => _$args;

  FutureOr<List<Observation>> build(String hikingHistoryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<Observation>>, List<Observation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Observation>>, List<Observation>>,
              AsyncValue<List<Observation>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
