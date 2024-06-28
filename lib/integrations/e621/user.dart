import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';

class E621UserService extends UserService {
  E621UserService({required this.dio});

  final Dio dio;

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
            (response) => E621User.fromJson(response.data),
          );

  @override
  Future<void> report({
    required int id,
    required String reason,
  }) =>
      dio.post(
        '/tickets',
        queryParameters: {
          'ticket[reason]': reason,
          'ticket[disp_id]': id,
          'ticket[qtype]': 'user',
        },
      );
}

extension E621User on User {
  static User fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => User(
          id: json['id'],
          name: json['name'],
          avatarId: json['avatar_id'],
          about: UserAbout(
            bio: json['profile_about'],
            comission: json['profile_artinfo'],
          ),
          stats: UserStats(
            createdAt: pick('created_at').asDateTimeOrThrow(),
            levelString: pick('level_string').asStringOrThrow(),
            favoriteCount: pick('favorite_count').asIntOrThrow(),
            postUpdateCount: pick('post_update_count').asIntOrThrow(),
            postUploadCount: pick('post_upload_count').asIntOrThrow(),
            forumPostCount: pick('forum_post_count').asIntOrThrow(),
            commentCount: pick('comment_count').asIntOrThrow(),
          ),
        ),
      );
}
