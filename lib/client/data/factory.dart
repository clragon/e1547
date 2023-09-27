import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ClientType {
  e621,
}

class ClientConfig {
  ClientConfig({
    required this.identity,
    required this.traits,
    required this.userAgent,
    this.cache,
  });

  final Identity identity;
  final ValueNotifier<Traits> traits;
  final String userAgent;
  final CacheStore? cache;
}

const String _e621Host = 'https://e621.net';
const String _e926Host = 'https://e926.net';

class ClientFactory {
  Client create(ClientConfig config) {
    switch (config.identity.type) {
      case ClientType.e621:
        return Client(
          identity: config.identity,
          traits: config.traits,
          userAgent: config.userAgent,
          cache: config.cache,
        );
    }
  }

  IdentityRequest createDefaultIdentity() {
    return const IdentityRequest(
      host: _e926Host,
      type: ClientType.e621,
    );
  }

  TraitsRequest createDefaultTraits(Identity identity) {
    return switch (identity.host) {
      _e621Host || _e926Host => TraitsRequest(
          identity: identity.id,
          denylist: ['young -rating:s', 'gore', 'scat', 'watersports'],
          homeTags: 'score:>=20',
        ),
      _ => TraitsRequest(
          identity: identity.id,
        ),
    };
  }

  String? registrationUrl(String host) {
    return switch (host) {
      _e621Host || _e926Host => '$host/users/new',
      _ => null,
    };
  }

  String? apiKeysUrl(String host, String username) {
    if (username.isEmpty) return null;
    return switch (host) {
      _e621Host || _e926Host => '$host/users/$username/api_key',
      _ => null,
    };
  }

  String? unsafeHostUrl(String host) {
    return switch (host) {
      _e926Host => _e621Host,
      _ => null,
    };
  }

  ClientType? typeFromUrl(String url) {
    return switch (normalizeHostUrl(url)) {
      _e621Host => ClientType.e621,
      _e926Host => ClientType.e621,
      _ => null,
    };
  }
}
