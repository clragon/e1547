import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/data/client_cache.dart';
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
  Domain({required this.dio, required this.persona}) : cache = ClientCache() {
    _postsClient = PostClient(dio: dio, cache: cache.posts);
    _accountClient = AccountClient(dio: dio);
    _poolClient = PoolClient(dio: dio);
    _userClient = UserClient(dio: dio);
    _commentClient = CommentClient(dio: dio, cache: cache.comments);
    _tagClient = TagClient(dio: dio, cache: cache.tags);
    _flagClient = FlagClient(dio: dio, cache: cache.flags);
    _wikiClient = WikiClient(dio: dio, cache: cache.wikis);
    _topicClient = TopicClient(dio: dio, cache: cache.topics);
    _replyClient = ReplyClient(dio: dio, cache: cache.replies);
    _ticketClient = TicketClient(dio: dio);

    posts = PostRepo(client: _postsClient, persona: persona);
    pools = PoolRepo(client: _poolClient, persona: persona);
    users = UserRepo(client: _userClient, persona: persona);
    comments = CommentRepo(client: _commentClient, persona: persona);
    tags = TagRepo(client: _tagClient, persona: persona);
    flags = FlagRepo(client: _flagClient, persona: persona);
    wikis = WikiRepo(client: _wikiClient, persona: persona);
    topics = TopicRepo(client: _topicClient, persona: persona);
    replies = ReplyRepo(client: _replyClient, persona: persona);
    tickets = TicketRepo(client: _ticketClient, persona: persona);
    account = AccountRepo(
      client: _accountClient,
      postClient: _postsClient,
      persona: persona,
    );
  }

  final Dio dio;
  final Persona persona;
  final ClientCache cache;

  late final AccountRepo account;
  late final PostRepo posts;
  late final PoolRepo pools;
  late final UserRepo users;
  late final CommentRepo comments;
  late final TagRepo tags;
  late final FlagRepo flags;
  late final WikiRepo wikis;
  late final TopicRepo topics;
  late final ReplyRepo replies;
  late final TicketRepo tickets;

  late final AccountClient _accountClient;
  late final PostClient _postsClient;
  late final PoolClient _poolClient;
  late final UserClient _userClient;
  late final CommentClient _commentClient;
  late final TagClient _tagClient;
  late final FlagClient _flagClient;
  late final WikiClient _wikiClient;
  late final TopicClient _topicClient;
  late final ReplyClient _replyClient;
  late final TicketClient _ticketClient;

  void dispose() {
    dio.close();
    for (final client in [
      _accountClient,
      _postsClient,
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
