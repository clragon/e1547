import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart' show CancelToken;

class Domain with Disposable {
  Domain({required this.identity, required this.traits, required this.storage})
    : dio = createDefaultDio(identity, cache: storage.httpCache);

  final Dio dio;
  final AppStorage storage;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  late final AccountService accounts = AccountService(
    dio: dio,
    identity: identity,
    traits: traits,
    postsService: posts,
  );
  late final UserService users = UserService(dio: dio);

  late final PostService posts = PostService(
    dio: dio,
    identity: identity,
    poolsService: pools,
  );

  late final TagService tags = TagService(dio: dio);
  late final WikiService wikis = WikiService(dio: dio);

  late final CommentService comments = CommentService(dio: dio);

  late final PoolService pools = PoolService(dio: dio);
  // TODO: add Sets

  late final TopicService topics = TopicService(dio: dio);
  late final ReplyService replies = ReplyService(dio: dio);

  late final FlagService flags = FlagService(dio: dio);
  late final TicketService tickets = TicketService(dio: dio);

  late final FollowService follows = FollowService(
    database: storage.sqlite,
    identity: identity,
    traits: traits,
    postsClient: posts,
    poolsClient: pools,
    tagsClient: tags,
  );

  late final HistoryService histories = HistoryService(
    database: storage.sqlite,
    preferences: storage.preferences,
    identity: identity,
    traits: traits,
  );

  @override
  void dispose() {
    dio.close();
    super.dispose();
  }
}

extension DomainExtension on Domain {
  String get host => identity.host;
  bool get hasLogin => identity.username != null;
  String withHost(String path) => identity.withHost(path);
}
