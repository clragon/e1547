import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/integrations/e621/account.dart';
import 'package:e1547/integrations/e621/comment.dart';
import 'package:e1547/integrations/e621/follow.dart';
import 'package:e1547/integrations/e621/pool.dart';
import 'package:e1547/integrations/e621/post.dart';
import 'package:e1547/integrations/e621/reply.dart';
import 'package:e1547/integrations/e621/tags.dart';
import 'package:e1547/integrations/e621/topic.dart';
import 'package:e1547/integrations/e621/traits.dart';
import 'package:e1547/integrations/e621/user.dart';
import 'package:e1547/integrations/e621/wiki.dart';
import 'package:e1547/integrations/http/availability.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class E621Client extends Client with ClientAssembly {
  E621Client({
    required this.identity,
    required this.traitsState,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    late PostsClient posts;
    late final accounts = E621AccountsClient(
      dio: dio,
      identity: identity,
      traits: traitsState,
      postsClient: posts,
    );
    final availability = HttpAvailabilityClient(
      dio: dio,
      identity: identity,
      traits: traitsState,
    );
    final comments = E621CommentsClient(dio: dio);
    final pools = E621PoolsClient(
      dio: dio,
      postsClient: E621PostsClient(
        dio: dio,
        identity: identity,
      ),
    );
    posts = E621PostsClient(
      dio: dio,
      identity: identity,
      poolsClient: pools,
    );
    final replies = E621RepliesClient(dio: dio);
    final tags = E621TagsClient(dio: dio);
    final topics = E621TopicsClient(dio: dio);
    final traits = E621TraitsClient(
      dio: dio,
      identity: identity,
      traits: traitsState,
      accountsClient: accounts,
    );
    final users = E621UsersClient(dio: dio);
    final wikis = E621WikisClient(dio: dio);
    final follows = E621FollowsClient(
      database: storage.sqlite,
      identity: identity,
      traits: traitsState,
      postsClient: posts,
      poolsClient: pools,
      tagsClient: tags,
    );

    enableClients(
      accounts: accounts,
      availability: availability,
      comments: comments,
      pools: pools,
      posts: posts,
      replies: replies,
      tags: tags,
      topics: topics,
      traits: traits,
      users: users,
      wikis: wikis,
      follows: follows,
    );
  }

  final Dio dio;

  final AppStorage storage;

  @override
  final Identity identity;

  @override
  final ValueNotifier<Traits> traitsState;

  @override
  void dispose() {
    super.dispose();
    dio.close();
  }
}
