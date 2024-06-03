import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';

class DanbooruUserService extends UserService {
  DanbooruUserService({required this.dio});

  final Dio dio;

  @override
  Set<UserFeature> get features => {};

  @override
  Future<User> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      dio
          .get(
            '/users/$id.json',
            options: forceOptions(force),
            cancelToken: cancelToken,
          )
          .then(
            (response) => DanbooruUser.fromJson(response.data),
          );
}

extension DanbooruUser on User {
  static User fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => User(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          avatarId: null,
          about: null,
          stats: UserStats(
            createdAt: pick('created_at').asDateTimeOrThrow(),
            levelString: pick('level_string').asStringOrThrow(),
            favoriteCount: null,
            postUpdateCount: pick('post_update_count').asIntOrThrow(),
            postUploadCount: pick('post_upload_count').asIntOrThrow(),
            forumPostCount: null,
            commentCount: null,
          ),
        ),
      );
}
