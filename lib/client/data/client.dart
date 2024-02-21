import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';

export 'package:dio/dio.dart' show CancelToken;

class Client {
  Client({
    required this.identity,
    required this.traits,
    this.cache,
  }) : status = ValueNotifier(const ClientSyncStatus()) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _host,
        headers: {
          HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
          ...?identity.headers,
        },
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(NewlineReplaceInterceptor());
    _dio.interceptors.add(LoggingDioInterceptor());
    if (cache != null) {
      _dio.interceptors.add(
        ClientCacheInterceptor(
          options: ClientCacheConfig(
            store: cache,
            maxAge: const Duration(minutes: 5),
            pageParam: 'page',
          ),
        ),
      );
    }
  }

  void dispose() {
    _dio.close();
  }

  /// The user identity of this client.
  final Identity identity;

  /// The settings for this identity.
  final ValueNotifier<Traits> traits;

  /// The sync status of this client.
  final ValueNotifier<ClientSyncStatus> status;

  /// The cache to use for this client.
  final CacheStore? cache;

  late Dio _dio;

  late final String _host = normalizeHostUrl(identity.host);

  String get host => identity.host;

  bool get hasLogin => identity.username != null;

  /// Appends [value] to [host] and returns the result.
  String withHost(String value) {
    throw UnmigratedError();
  }

  Future<void> availability() async {
    throw UnmigratedError();
  }

  Future<List<Post>> posts({
    int? page,
    int? limit,
    QueryMap? query,
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Post>> postsByIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Post>> postsByTags(
    List<String> tags,
    int page, {
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Post>> postsByFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Post>> postsByUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Post> post(int postId, {bool? force, CancelToken? cancelToken}) async {
    throw UnmigratedError();
  }

  Future<void> updatePost(int postId, Map<String, String?> body) async {
    throw UnmigratedError();
  }

  Future<void> votePost(int postId, bool upvote, bool replace) async {
    throw UnmigratedError();
  }

  Future<void> reportPost(int postId, int reportId, String reason) async {
    throw UnmigratedError();
  }

  Future<void> flagPost(int postId, String flag, {int? parent}) async {
    throw UnmigratedError();
  }

  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? orderByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<void> addFavorite(int postId) async {
    throw UnmigratedError();
  }

  Future<void> removeFavorite(int postId) async {
    throw UnmigratedError();
  }

  Future<List<PostFlag>> flags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Pool>> pools({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Pool> pool({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Post>> postsByPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Wiki>> wikis({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Wiki> wiki({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<User> user({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<void> reportUser({
    required int id,
    required String reason,
  }) async {
    throw UnmigratedError();
  }

  Future<Account?> account({
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<void> updateTraits({
    required Traits traits,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<void> syncTraits({bool? force, CancelToken? cancelToken}) async {
    throw UnmigratedError();
  }

  Future<List<Tag>> tags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Tag>> autocomplete({
    required String search,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<String?> tagAliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Comment>> comments({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Comment>> commentsByPost({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Comment> comment({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<void> postComment({
    required int postId,
    required String content,
  }) async {
    throw UnmigratedError();
  }

  Future<void> updateComment({
    required int id,
    required int postId,
    required String content,
  }) async {
    throw UnmigratedError();
  }

  Future<void> voteComment({
    required int id,
    required bool upvote,
    required bool replace,
  }) async {
    throw UnmigratedError();
  }

  Future<void> reportComment({
    required int id,
    required String reason,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Topic>> topics({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Topic> topic({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Reply>> replies({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<List<Reply>> repliesByTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }

  Future<Reply> reply({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) async {
    throw UnmigratedError();
  }
}

class UnmigratedError extends UnimplementedError {
  UnmigratedError() : super('This feature is not yet migrated.');
}

// TODO: create a call parameters class with force and cancelToken
// TODO: create a subclass for call parameters with pagination
