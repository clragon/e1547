import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/integrations/danbooru.dart';
import 'package:e1547/integrations/integrations.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

enum ClientType {
  e621,
  danbooru,
}

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
const String _danbooruHost = 'https://danbooru.donmai.us';
const String _safeDanbooruHost = 'https://safebooru.donmai.us';

class ClientFactory {
  Client create(ClientConfig config) => switch (config.identity.type) {
        ClientType.e621 => E621Client(
            identity: config.identity,
            traitsState: config.traits,
            storage: config.storage,
          ),
        ClientType.danbooru => DanbooruClient(
            identity: config.identity,
            traitsState: config.traits,
            storage: config.storage,
          ),
      };

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
      _danbooruHost || _safeDanbooruHost => TraitsRequest(
          identity: identity.id,
          denylist: [],
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
      _danbooruHost || _safeDanbooruHost => '$host/users/new',
      _ => null,
    };
  }

  String? apiKeysUrl(String host, String username) {
    if (username.isEmpty) return null;
    return switch (host) {
      _e621Host || _e926Host => '$host/users/$username/api_key',
      _danbooruHost || _safeDanbooruHost => '$host/users/$username/api_keys',
      _ => null,
    };
  }

  String? unsafeHostUrl(String host) {
    return switch (host) {
      _e926Host => _e621Host,
      _safeDanbooruHost => _danbooruHost,
      _ => null,
    };
  }

  ClientType? typeFromUrl(String url) {
    return switch (normalizeHostUrl(url)) {
      _e621Host || _e926Host => ClientType.e621,
      _danbooruHost || _safeDanbooruHost => ClientType.danbooru,
      _ => null,
    };
  }
}
