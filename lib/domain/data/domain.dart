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
    poolsService: pools,
  );

  late final TagClient tags = TagClient(dio: dio);
  late final WikiClient wikis = WikiClient(dio: dio);

  late final CommentClient _comments = CommentClient(
    dio: dio,
    cache: storage.clientCache.comments,
  );
  late final CommentRepo comments = CommentRepo(
    persona: persona,
    client: _comments,
  );

  late final PoolClient pools = PoolClient(dio: dio);
  // TODO: add Sets

  late final TopicClient topics = TopicClient(dio: dio);
  late final ReplyClient replies = ReplyClient(dio: dio);

  late final FlagClient flags = FlagClient(dio: dio);
  late final TicketClient tickets = TicketClient(dio: dio);

  late final FollowClient follows = FollowClient(
    database: storage.sqlite,
    identity: identity,
    traits: traits,
    postsClient: posts,
    poolsClient: pools,
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
