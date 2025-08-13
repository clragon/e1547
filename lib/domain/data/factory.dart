import 'package:e1547/app/app.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class ClientConfig {
  ClientConfig({
    required this.identity,
    required this.traits,
    required this.storage,
  });

  final Identity identity;
  final ValueNotifier<Traits> traits;
  final AppStorage storage;
}

const String _e621Host = 'https://e621.net';
const String _e926Host = 'https://e926.net';

class ClientFactory {
  Domain create(ClientConfig config) => Domain(
    identity: config.identity,
    traits: config.traits,
    storage: config.storage,
  );

  IdentityRequest createDefaultIdentity() {
    return const IdentityRequest(host: _e926Host);
  }

  TraitsRequest createDefaultTraits(Identity identity) {
    return switch (normalizeHostUrl(identity.host)) {
      _e621Host || _e926Host => TraitsRequest(
        identity: identity.id,
        denylist: ['young -rating:s', 'gore', 'scat', 'watersports'],
        homeTags: 'score:>=20',
      ),
      _ => TraitsRequest(identity: identity.id),
    };
  }

  String? registrationUrl(String host) {
    return switch (normalizeHostUrl(host)) {
      _e621Host || _e926Host => '$host/users/new',
      _ => null,
    };
  }

  String? apiKeysUrl(String host, String username) {
    if (username.isEmpty) return null;
    return switch (normalizeHostUrl(host)) {
      _e621Host || _e926Host => '$host/users/$username/api_key',
      _ => null,
    };
  }

  String? unsafeHostUrl(String host) {
    return switch (normalizeHostUrl(host)) {
      _e926Host => _e621Host,
      _ => null,
    };
  }
}
