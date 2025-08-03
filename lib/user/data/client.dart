import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:e1547/user/user.dart';

class UserClient {
  UserClient({required this.dio});

  final Dio dio;
  final ValueCache<QueryKey, User> cache = ValueCache(
    size: null,
    maxAge: const Duration(minutes: 5),
  );

  Future<User> get({required int id, bool? force, CancelToken? cancelToken}) =>
      cache
          .stream(
            QueryKey([id]),
            fetch: () => dio
                .get('/users/$id.json', cancelToken: cancelToken)
                .then((response) => E621User.fromJson(response.data)),
          )
          .future;

  Future<User> getByName({
    required String name,
    bool? force,
    CancelToken? cancelToken,
  }) => cache
      .stream(
        QueryKey([name]),
        fetch: () => dio
            .get('/users/$name.json', cancelToken: cancelToken)
            .then((response) => E621User.fromJson(response.data)),
      )
      .future;

  Future<List<User>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/users.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrThrow((e) => E621User.fromJson(e)).toList(),
      );

  void dispose() {
    cache.dispose();
  }
}

extension E621User on User {
  static User fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => User(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      avatarId: pick('avatar_id').asIntOrNull(),
      about: UserAbout(
        bio: pick('profile_about').asStringOrNull(),
        comission: pick('profile_artinfo').asStringOrNull(),
      ),
      stats: UserStats(
        createdAt: pick('created_at').asDateTimeOrNull(),
        levelString: pick('level_string').asStringOrNull(),
        favoriteCount: pick('favorite_count').asIntOrNull(),
        postUpdateCount: pick('post_update_count').asIntOrNull(),
        postUploadCount: pick('post_upload_count').asIntOrNull(),
        forumPostCount: pick('forum_post_count').asIntOrNull(),
        commentCount: pick('comment_count').asIntOrNull(),
      ),
    ),
  );
}
