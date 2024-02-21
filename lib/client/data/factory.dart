import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/client/integrations/integrations.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/data/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/data/client.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

enum ClientType {
  e621,
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

class ClientBundle {
  ClientBundle({
    required this.accounts,
    required this.availability,
    required this.comments,
    required this.pools,
    required this.posts,
    required this.replies,
    required this.tags,
    required this.topics,
    required this.traits,
    required this.users,
    required this.wikis,
    this.onDispose,
  });

  final AccountsClient? accounts;
  final AvailabilityClient? availability;
  final CommentsClient? comments;
  final PoolsClient? pools;
  final PostsClient? posts;
  final RepliesClient? replies;
  final TagsClient? tags;
  final TopicsClient? topics;
  final TraitsClient? traits;
  final UsersClient? users;
  final WikisClient? wikis;

  final VoidCallback? onDispose;

  void dispose() => onDispose?.call();
}

const String _e621Host = 'https://e621.net';
const String _e926Host = 'https://e926.net';

class ClientFactory {
  ClientBundle create(ClientConfig config) {
    switch (config.identity.type) {
      case ClientType.e621:
        final identity = config.identity;
        final traits = config.traits;
        final dio = createDefaultDio(identity);
        final postsClient = E621PostsClient(dio: dio, identity: identity);
        final accountsClient = E621AccountsClient(
          dio: dio,
          identity: identity,
          traits: traits,
          postsClient: postsClient,
        );
        return ClientBundle(
          accounts: accountsClient,
          availability: HttpAvailabilityClient(
            dio: dio,
            identity: identity,
            traits: traits,
          ),
          comments: E621CommentsClient(dio: dio),
          pools: E621PoolsClient(
            dio: dio,
            postsClient: postsClient,
          ),
          posts: postsClient,
          replies: E621RepliesClient(dio: dio),
          tags: E621TagsClient(dio: dio),
          topics: E621TopicsClient(dio: dio),
          traits: E621TraitsClient(
            dio: dio,
            identity: identity,
            traits: traits,
            accountsClient: accountsClient,
          ),
          users: E621UsersClient(dio: dio),
          wikis: E621WikisClient(dio: dio),
          onDispose: () => dio.close(),
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
      _e621Host || _e926Host => ClientType.e621,
      _ => null,
    };
  }
}
