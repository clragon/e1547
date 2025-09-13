import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/favorite/favorite.dart';
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
    postsService: _posts,
  );

  late final UserClient _users = UserClient(dio: dio);
  late final UserRepo users = UserRepo(
    persona: persona,
    client: _users,
    cache: storage.queryCache,
  );

  late final PostClient _posts = PostClient(dio: dio);
  late final PostRepo posts = PostRepo(
    persona: persona,
    client: _posts,
    cache: storage.queryCache,
  );

  late final FavoriteClient _favorites = FavoriteClient(dio: dio);
  late final FavoriteRepo favorites = FavoriteRepo(
    persona: persona,
    client: _favorites,
    cache: storage.queryCache,
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
    postClient: _posts,
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

  late final FollowClient _follows = FollowClient(database: storage.sqlite);
  late final FollowRepo follows = FollowRepo(
    persona: persona,
    client: _follows,
    cache: storage.queryCache,
  );

  late final FollowServer followsServer = FollowServer(
    client: _follows,
    persona: persona,
    postsClient: _posts,
    poolsClient: _pools,
    tagsClient: tags,
  );

  late final HistoryClient _histories = HistoryClient(database: storage.sqlite);
  late final HistoryRepo histories = HistoryRepo(
    persona: persona,
    client: _histories,
    cache: storage.queryCache,
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
