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
  Domain({required this.persona, required this.storage})
    : dio = createDefaultDio(persona.identity, cache: storage.httpCache);

  final Dio dio;
  final AppStorage storage;

  final Persona persona;

  Identity get identity => persona.identity;
  ValueNotifier<Traits> get traits => persona.traits;

  late final AccountClient accounts = AccountClient(
    dio: dio,
    identity: identity,
    traits: traits,
    postsService: posts,
  );
  late final UserClient users = UserClient(dio: dio);

  late final PostClient posts = PostClient(
    dio: dio,
    identity: identity,
    poolsService: _pools,
  );

  late final TagClient tags = TagClient(dio: dio);
  late final WikiClient wikis = WikiClient(dio: dio);

  late final CommentClient _comments = CommentClient(dio: dio);
  late final CommentRepo comments = CommentRepo(
    persona: persona,
    client: _comments,
    cache: storage.queryCache,
  );

  late final PoolClient _pools = PoolClient(dio: dio);
  late final PoolRepo pools = PoolRepo(
    persona: persona,
    client: _pools,
    cache: storage.queryCache,
  );
  // TODO: add Sets

  late final TopicClient _topics = TopicClient(dio: dio);
  late final TopicRepo topics = TopicRepo(
    persona: persona,
    client: _topics,
    cache: storage.queryCache,
  );

  late final ReplyClient _replies = ReplyClient(dio: dio);
  late final ReplyRepo replies = ReplyRepo(
    persona: persona,
    client: _replies,
    cache: storage.queryCache,
  );

  late final FlagClient flags = FlagClient(dio: dio);
  late final TicketClient tickets = TicketClient(dio: dio);

  late final FollowClient follows = FollowClient(
    database: storage.sqlite,
    identity: identity,
    traits: traits,
    postsClient: posts,
    poolsClient: _pools,
    tagsClient: tags,
  );

  late final HistoryClient histories = HistoryClient(
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
