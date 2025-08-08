import 'dart:async';

import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class PersonaController
    with ChangeNotifier
    implements ValueListenable<Persona> {
  PersonaController({required this.identityRepo, required this.traitsRepo});

  final IdentityRepo identityRepo;
  final TraitsRepo traitsRepo;

  static const String _e621Host = 'https://e621.net';
  static const String _e926Host = 'https://e926.net';

  Persona? _value;

  @override
  Persona get value {
    if (_value == null) {
      throw StateError(
        'PersonaController was not activated before accessing value',
      );
    }
    return _value!;
  }

  StreamSubscription<Identity?>? _identitySubscription;
  StreamSubscription<Traits?>? _traitsSubscription;

  bool _disposed = false;

  Future<void> activate([int? identityId]) async {
    _identitySubscription?.cancel();
    _traitsSubscription?.cancel();

    Identity? identity;

    // Get identity
    if (identityId != null) {
      identity = await identityRepo.getOrNull(identityId);
    }

    // Fallback to first identity if none specified or found
    if (identity == null) {
      final identities = await identityRepo.page(page: 1, limit: 1);
      identity = identities.isEmpty ? null : identities.first;
    }

    // Create default identity if none exists
    identity ??= await identityRepo.add(await _createDefaultIdentity());

    if (_disposed) return;

    // Get traits for the identity
    Traits? traits = await traitsRepo.getOrNull(identity.id);

    // Create default traits if none exists
    traits ??= await traitsRepo.add(await _createDefaultTraits(identity));

    if (_disposed) return;

    // Create traits notifier with streaming support
    final traitsStream = traitsRepo
        .getOrNull(identity.id)
        .stream
        .whereNotNull();

    final traitsNotifier = _StreamedValueNotifier<Traits>(
      initial: traits,
      stream: traitsStream,
      onChanged: (newTraits) => traitsRepo.replace(newTraits),
    );

    // Update current persona
    _value = (identity: identity, traits: traitsNotifier);

    // Set up subscriptions to watch for changes
    _identitySubscription = identityRepo
        .getOrNull(identity.id)
        .stream
        .listen(_onIdentityChanged);
    _traitsSubscription = traitsRepo
        .getOrNull(identity.id)
        .stream
        .listen((traits) => _onTraitsChanged(traits, traitsNotifier));

    if (_disposed) return;
    notifyListeners();
  }

  Future<void> _onIdentityChanged(Identity? newIdentity) async {
    if (newIdentity == null) {
      // Identity was deleted, reactivate with no specific ID
      return activate();
    }

    if (newIdentity == value.identity) return;

    // Identity changed, update the persona
    _value = (identity: newIdentity, traits: value.traits);
    notifyListeners();
  }

  Future<void> _onTraitsChanged(
    Traits? newTraits,
    ValueNotifier<Traits> traitsNotifier,
  ) async {
    if (newTraits == null) {
      // Traits were deleted, recreate default traits
      final defaultTraits = await traitsRepo.add(
        await _createDefaultTraits(value.identity),
      );
      traitsNotifier.value = defaultTraits;
      return;
    }

    if (newTraits == traitsNotifier.value) return;

    // Traits changed, update the notifier
    traitsNotifier.value = newTraits;
  }

  Future<IdentityRequest> _createDefaultIdentity() async =>
      const IdentityRequest(host: _e926Host);

  Future<TraitsRequest> _createDefaultTraits(Identity identity) async =>
      switch (normalizeHostUrl(identity.host)) {
        _e621Host || _e926Host => TraitsRequest(
          identity: identity.id,
          denylist: ['young -rating:s', 'gore', 'scat', 'watersports'],
          homeTags: 'score:>=20',
        ),
        _ => TraitsRequest(identity: identity.id),
      };

  @override
  void dispose() {
    _disposed = true;
    _identitySubscription?.cancel();
    _traitsSubscription?.cancel();
    value.traits.dispose();
    super.dispose();
  }
}

class _StreamedValueNotifier<T> extends ValueNotifier<T> {
  _StreamedValueNotifier({
    required T initial,
    required this.stream,
    required this.onChanged,
  }) : super(initial) {
    _subscription = stream.listen((value) => this.value = value);
  }

  final Stream<T> stream;
  final ValueSetter<T> onChanged;

  StreamSubscription<T>? _subscription;

  @override
  set value(T newValue) {
    if (newValue != value) {
      onChanged(newValue);
    }
    super.value = newValue;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
