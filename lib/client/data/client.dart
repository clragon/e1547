import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart' show CancelToken;

enum ClientFeature {
  accounts,
  bridge,
  comments,
  pools,
  posts,
  replies,
  tags,
  topics,
  users,
  wikis,
  follows,
  histories,
}

abstract class Client with Disposable {
  Identity get identity;
  ValueNotifier<Traits> get traits;

  AccountService get accounts;
  BridgeService get bridge;
  CommentService get comments;
  PoolService get pools;
  PostService get posts;
  ReplyService get replies;
  TagService get tags;
  TopicService get topics;
  UserService get users;
  WikiService get wikis;
  FollowService get follows;
  HistoryService get histories;
}

extension ClientExtension on Client {
  String get host => identity.host;
  bool get hasLogin => identity.username != null;
  String withHost(String path) => identity.withHost(path);
}
