import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/follow/follow.dart';
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
  availability,
  comments,
  pools,
  posts,
  replies,
  tags,
  topics,
  traits,
  users,
  wikis,
  follows,
}

abstract class Client with FeatureFlagging<Enum>, Disposable {
  Identity get identity;
  ValueNotifier<Traits> get traitsState;

  AccountsClient get accounts => throwUnsupported(ClientFeature.accounts);
  AvailabilityClient get availability =>
      throwUnsupported(ClientFeature.availability);
  CommentsClient get comments => throwUnsupported(ClientFeature.comments);
  PoolsClient get pools => throwUnsupported(ClientFeature.pools);
  PostsClient get posts => throwUnsupported(ClientFeature.posts);
  RepliesClient get replies => throwUnsupported(ClientFeature.replies);
  TagsClient get tags => throwUnsupported(ClientFeature.tags);
  TopicsClient get topics => throwUnsupported(ClientFeature.topics);
  TraitsClient get traits => throwUnsupported(ClientFeature.traits);
  UsersClient get users => throwUnsupported(ClientFeature.users);
  WikisClient get wikis => throwUnsupported(ClientFeature.wikis);
  FollowsClient get follows => throwUnsupported(ClientFeature.follows);
}

extension ClientExtension on Client {
  String get host => identity.host;
  bool get hasLogin => identity.username != null;
  String withHost(String path) => identity.withHost(path);
}

mixin ClientAssembly on Client {
  @protected
  void enableClients({
    AccountsClient? accounts,
    AvailabilityClient? availability,
    CommentsClient? comments,
    PoolsClient? pools,
    PostsClient? posts,
    RepliesClient? replies,
    TagsClient? tags,
    TopicsClient? topics,
    TraitsClient? traits,
    UsersClient? users,
    WikisClient? wikis,
    FollowsClient? follows,
  }) {
    _accounts = accounts;
    _availability = availability;
    _comments = comments;
    _pools = pools;
    _posts = posts;
    _replies = replies;
    _tags = tags;
    _topics = topics;
    _traits = traits;
    _users = users;
    _wikis = wikis;
    _follows = follows;

    _features = _generateFeatures();
  }

  late final Set<Enum> _features;

  @override
  Set<Enum> get features => _features;

  Set<Object?> get _clients => {
        _accounts,
        _availability,
        _comments,
        _pools,
        _posts,
        _replies,
        _tags,
        _topics,
        _traits,
        _users,
        _wikis,
        _follows,
      };

  Set<Enum> _generateFeatures() => {
        // client features
        if (_accounts != null) ClientFeature.accounts,
        if (_availability != null) ClientFeature.availability,
        if (_comments != null) ClientFeature.comments,
        if (_pools != null) ClientFeature.pools,
        if (_posts != null) ClientFeature.posts,
        if (_replies != null) ClientFeature.replies,
        if (_tags != null) ClientFeature.tags,
        if (_topics != null) ClientFeature.topics,
        if (_traits != null) ClientFeature.traits,
        if (_users != null) ClientFeature.users,
        if (_wikis != null) ClientFeature.wikis,
        if (_follows != null) ClientFeature.follows,
        // sub features
        ..._clients
            .whereType<FeatureFlagging<Enum>>()
            .fold<Set<Enum>>({}, (all, e) => all..addAll(e.features)),
      };

  late final AccountsClient? _accounts;
  late final AvailabilityClient? _availability;
  late final CommentsClient? _comments;
  late final PoolsClient? _pools;
  late final PostsClient? _posts;
  late final RepliesClient? _replies;
  late final TagsClient? _tags;
  late final TopicsClient? _topics;
  late final TraitsClient? _traits;
  late final UsersClient? _users;
  late final WikisClient? _wikis;
  late final FollowsClient? _follows;

  T _throwOnMissingClient<T>(T? client, ClientFeature flag) {
    if (client == null) throwUnsupported(flag);
    return client;
  }

  @override
  AccountsClient get accounts =>
      _throwOnMissingClient(_accounts, ClientFeature.accounts);
  @override
  AvailabilityClient get availability =>
      _throwOnMissingClient(_availability, ClientFeature.availability);
  @override
  CommentsClient get comments =>
      _throwOnMissingClient(_comments, ClientFeature.comments);
  @override
  PoolsClient get pools => _throwOnMissingClient(_pools, ClientFeature.pools);
  @override
  PostsClient get posts => _throwOnMissingClient(_posts, ClientFeature.posts);
  @override
  RepliesClient get replies =>
      _throwOnMissingClient(_replies, ClientFeature.replies);
  @override
  TagsClient get tags => _throwOnMissingClient(_tags, ClientFeature.tags);
  @override
  TopicsClient get topics =>
      _throwOnMissingClient(_topics, ClientFeature.topics);
  @override
  TraitsClient get traits =>
      _throwOnMissingClient(_traits, ClientFeature.traits);
  @override
  UsersClient get users => _throwOnMissingClient(_users, ClientFeature.users);
  @override
  WikisClient get wikis => _throwOnMissingClient(_wikis, ClientFeature.wikis);
  @override
  FollowsClient get follows =>
      _throwOnMissingClient(_follows, ClientFeature.follows);

  @override
  void dispose() {
    for (final client in _clients) {
      if (client is Disposable) {
        client.dispose();
      }
    }
    super.dispose();
  }
}
