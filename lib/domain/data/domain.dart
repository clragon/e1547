import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/data/client_cache.dart';
import 'package:e1547/favorite/favorite.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';

class Domain {
  Domain({required this.dio, required this.persona}) : cache = ClientCache();

  final Dio dio;
  final Persona persona;
  final ClientCache cache;

  late final AccountClient _accountClient = AccountClient(dio: dio);
  late final PostClient _postsClient = PostClient(dio: dio, cache: cache.posts);
  late final FavoriteClient _favoriteClient = FavoriteClient(
    dio: dio,
    postCache: cache.posts,
  );
  late final PoolClient _poolClient = PoolClient(dio: dio);
  late final UserClient _userClient = UserClient(dio: dio);
  late final CommentClient _commentClient = CommentClient(
    dio: dio,
    cache: cache.comments,
  );
  late final TagClient _tagClient = TagClient(dio: dio, cache: cache.tags);
  late final FlagClient _flagClient = FlagClient(dio: dio, cache: cache.flags);
  late final WikiClient _wikiClient = WikiClient(dio: dio, cache: cache.wikis);
  late final TopicClient _topicClient = TopicClient(
    dio: dio,
    cache: cache.topics,
  );
  late final ReplyClient _replyClient = ReplyClient(
    dio: dio,
    cache: cache.replies,
  );
  late final TicketClient _ticketClient = TicketClient(dio: dio);

  late final AccountRepo account = AccountRepo(
    persona: persona,
    client: _accountClient,
    postClient: _postsClient,
  );
  late final PostRepo posts = PostRepo(
    persona: persona,
    client: _postsClient,
    favorites: _favoriteClient,
  );
  late final FavoriteRepo favorites = FavoriteRepo(
    persona: persona,
    client: _favoriteClient,
  );
  late final PoolRepo pools = PoolRepo(persona: persona, client: _poolClient);
  late final UserRepo users = UserRepo(persona: persona, client: _userClient);
  late final CommentRepo comments = CommentRepo(
    persona: persona,
    client: _commentClient,
  );
  late final TagRepo tags = TagRepo(persona: persona, client: _tagClient);
  late final FlagRepo flags = FlagRepo(persona: persona, client: _flagClient);
  late final WikiRepo wikis = WikiRepo(persona: persona, client: _wikiClient);
  late final TopicRepo topics = TopicRepo(
    persona: persona,
    client: _topicClient,
  );
  late final ReplyRepo replies = ReplyRepo(
    persona: persona,
    client: _replyClient,
  );
  late final TicketRepo tickets = TicketRepo(
    persona: persona,
    client: _ticketClient,
  );

  void dispose() {
    dio.close();
    for (final client in [
      _accountClient,
      _postsClient,
      _favoriteClient,
      _poolClient,
      _userClient,
      _commentClient,
      _tagClient,
      _flagClient,
      _wikiClient,
      _topicClient,
      _replyClient,
      _ticketClient,
    ]) {
      tryDispose(client);
    }
    cache.dispose();
  }
}
