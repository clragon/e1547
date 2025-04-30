import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/data/service.dart';
import 'package:e1547/follow/data/service.dart';
import 'package:e1547/history/data/service.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/integrations/disk/history.dart';
import 'package:e1547/integrations/e621/account.dart';
import 'package:e1547/integrations/e621/bridge.dart';
import 'package:e1547/integrations/e621/comment.dart';
import 'package:e1547/integrations/e621/follow.dart';
import 'package:e1547/integrations/e621/pool.dart';
import 'package:e1547/integrations/e621/post.dart';
import 'package:e1547/integrations/e621/reply.dart';
import 'package:e1547/integrations/e621/tags.dart';
import 'package:e1547/integrations/e621/topic.dart';
import 'package:e1547/integrations/e621/user.dart';
import 'package:e1547/integrations/e621/wiki.dart';
import 'package:e1547/pool/data/service.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/data/service.dart';
import 'package:e1547/tag/data/service.dart';
import 'package:e1547/topic/data/service.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/data/service.dart';
import 'package:e1547/wiki/data/service.dart';
import 'package:flutter/foundation.dart';

class E621Client extends Client {
  E621Client({
    required this.identity,
    required this.traits,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    comments = E621CommentService(dio: dio);
    pools = E621PoolService(
      dio: dio,
      postsClient: E621PostService(
        dio: dio,
        identity: identity,
      ),
    );
    posts = E621PostService(
      dio: dio,
      identity: identity,
      poolsClient: pools,
    );
    replies = E621ReplyService(dio: dio);
    tags = E621TagService(dio: dio);
    topics = E621TopicService(dio: dio);
    users = E621UserService(dio: dio);
    wikis = E621WikiService(dio: dio);
    follows = E621FollowService(
      database: storage.sqlite,
      identity: identity,
      traits: traits,
      postsClient: posts,
      poolsClient: pools,
      tagsClient: tags,
    );
    histories = DiskHistoryService(
      database: storage.sqlite,
      preferences: storage.preferences,
      identity: identity,
      traits: traits,
    );
    accounts = E621AccountService(
      dio: dio,
      identity: identity,
      traits: traits,
      postsClient: posts,
    );
    bridge = E621BridgeService(
      dio: dio,
      identity: identity,
      traits: traits,
      accountsService: accounts,
    );
  }

  final Dio dio;

  final AppStorage storage;

  @override
  final Identity identity;

  @override
  final ValueNotifier<Traits> traits;

  @override
  void dispose() {
    super.dispose();
    dio.close();
  }

  @override
  late final AccountService accounts;

  @override
  late final BridgeService bridge;

  @override
  late final CommentService comments;

  @override
  late final FollowService follows;

  @override
  late final HistoryService histories;

  @override
  late final PoolService pools;

  @override
  late final PostService posts;

  @override
  late final ReplyService replies;

  @override
  late final TagService tags;

  @override
  late final TopicService topics;

  @override
  late final UserService users;

  @override
  late final WikiService wikis;
}
