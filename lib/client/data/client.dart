import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
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

abstract class Client with FeatureFlagging<Enum>, Disposable {
  Identity get identity;
  ValueNotifier<Traits> get traits;

  AccountService get accounts => throwUnsupported(ClientFeature.accounts);
  BridgeService get bridge => throwUnsupported(ClientFeature.bridge);
  CommentService get comments => throwUnsupported(ClientFeature.comments);
  PoolService get pools => throwUnsupported(ClientFeature.pools);
  PostService get posts => throwUnsupported(ClientFeature.posts);
  ReplyService get replies => throwUnsupported(ClientFeature.replies);
  TagService get tags => throwUnsupported(ClientFeature.tags);
  TopicService get topics => throwUnsupported(ClientFeature.topics);
  UserService get users => throwUnsupported(ClientFeature.users);
  WikiService get wikis => throwUnsupported(ClientFeature.wikis);
  FollowService get follows => throwUnsupported(ClientFeature.follows);
  HistoryService get histories => throwUnsupported(ClientFeature.histories);
}

extension ClientExtension on Client {
  String get host => identity.host;
  bool get hasLogin => identity.username != null;
  String withHost(String path) => identity.withHost(path);
}

mixin ClientAssembly on Client {
  @protected
  void enableServices({
    AccountService? accounts,
    BridgeService? bridge,
    CommentService? comments,
    PoolService? pools,
    PostService? posts,
    ReplyService? replies,
    TagService? tags,
    TopicService? topics,
    UserService? users,
    WikiService? wikis,
    FollowService? follows,
    HistoryService? histories,
  }) {
    _accounts = accounts;
    _bridge = bridge;
    _comments = comments;
    _pools = pools;
    _posts = posts;
    _replies = replies;
    _tags = tags;
    _topics = topics;
    _users = users;
    _wikis = wikis;
    _follows = follows;
    _histories = histories;

    _features = _generateFeatures();
  }

  late final Set<Enum> _features;

  @override
  Set<Enum> get features => _features;

  Set<Object?> get _services => {
        _accounts,
        _bridge,
        _comments,
        _pools,
        _posts,
        _replies,
        _tags,
        _topics,
        _users,
        _wikis,
        _follows,
        _histories,
      };

  Set<Enum> _generateFeatures() => {
        // client features
        if (_accounts != null) ClientFeature.accounts,
        if (_bridge != null) ClientFeature.bridge,
        if (_comments != null) ClientFeature.comments,
        if (_pools != null) ClientFeature.pools,
        if (_posts != null) ClientFeature.posts,
        if (_replies != null) ClientFeature.replies,
        if (_tags != null) ClientFeature.tags,
        if (_topics != null) ClientFeature.topics,
        if (_users != null) ClientFeature.users,
        if (_wikis != null) ClientFeature.wikis,
        if (_follows != null) ClientFeature.follows,
        if (_histories != null) ClientFeature.histories,
        // sub features
        ..._services
            .whereType<FeatureFlagging<Enum>>()
            .fold<Set<Enum>>({}, (all, e) => all..addAll(e.features)),
      };

  late final AccountService? _accounts;
  late final BridgeService? _bridge;
  late final CommentService? _comments;
  late final PoolService? _pools;
  late final PostService? _posts;
  late final ReplyService? _replies;
  late final TagService? _tags;
  late final TopicService? _topics;
  late final UserService? _users;
  late final WikiService? _wikis;
  late final FollowService? _follows;
  late final HistoryService? _histories;

  T _throwOnMissingService<T>(T? client, ClientFeature flag) {
    if (client == null) throwUnsupported(flag);
    return client;
  }

  @override
  AccountService get accounts =>
      _throwOnMissingService(_accounts, ClientFeature.accounts);
  @override
  BridgeService get bridge =>
      _throwOnMissingService(_bridge, ClientFeature.bridge);
  @override
  CommentService get comments =>
      _throwOnMissingService(_comments, ClientFeature.comments);
  @override
  PoolService get pools => _throwOnMissingService(_pools, ClientFeature.pools);
  @override
  PostService get posts => _throwOnMissingService(_posts, ClientFeature.posts);
  @override
  ReplyService get replies =>
      _throwOnMissingService(_replies, ClientFeature.replies);
  @override
  TagService get tags => _throwOnMissingService(_tags, ClientFeature.tags);
  @override
  TopicService get topics =>
      _throwOnMissingService(_topics, ClientFeature.topics);
  @override
  UserService get users => _throwOnMissingService(_users, ClientFeature.users);
  @override
  WikiService get wikis => _throwOnMissingService(_wikis, ClientFeature.wikis);
  @override
  FollowService get follows =>
      _throwOnMissingService(_follows, ClientFeature.follows);
  @override
  HistoryService get histories =>
      _throwOnMissingService(_histories, ClientFeature.histories);

  @override
  void dispose() {
    for (final service in _services) {
      if (service is Disposable) {
        service.dispose();
      }
    }
    super.dispose();
  }
}
