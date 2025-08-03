import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/flag/flag.dart';
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
import 'package:flutter/material.dart';

class Client {
  Client({required this.dio, required this.identity, required this.traits});

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  late final AccountClient account = AccountClient(
    dio: dio,
    identity: identity,
    traits: traits,
    postClient: posts,
  );

  late final PostClient posts = PostClient(dio: dio);
  late final PoolClient pools = PoolClient(dio: dio);
  late final UserClient users = UserClient(dio: dio);
  late final CommentClient comments = CommentClient(dio: dio);
  late final TagClient tags = TagClient(dio: dio);
  late final FlagClient flags = FlagClient(dio: dio);
  late final WikiClient wikis = WikiClient(dio: dio);
  late final TopicClient topics = TopicClient(dio: dio);
  late final ReplyClient replies = ReplyClient(dio: dio);
  late final TicketClient tickets = TicketClient(dio: dio);

  void dispose() {
    dio.close();
    for (final client in [
      account,
      posts,
      pools,
      users,
      comments,
      tags,
      flags,
      wikis,
      topics,
      replies,
      tickets,
    ]) {
      tryDispose(client);
    }
  }
}
