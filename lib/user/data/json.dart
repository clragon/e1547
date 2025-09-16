import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/user/user.dart';

abstract final class E621User {
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
