import 'dart:convert';

class User {
  User({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.appealCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.id,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.baseUploadLimit,
    required this.postUploadCount,
    required this.postUpdateCount,
    required this.noteUpdateCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
    required this.avatarId,
  });

  int wikiPageVersionCount;
  int artistVersionCount;
  int poolVersionCount;
  int forumPostCount;
  int commentCount;
  int appealCount;
  int flagCount;
  int positiveFeedbackCount;
  int neutralFeedbackCount;
  int negativeFeedbackCount;
  int uploadLimit;
  int id;
  DateTime createdAt;
  String name;
  int level;
  int baseUploadLimit;
  int postUploadCount;
  int postUpdateCount;
  int noteUpdateCount;
  bool isBanned;
  bool canApprovePosts;
  bool canUploadFree;
  String levelString;
  int? avatarId;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        wikiPageVersionCount: json["wiki_page_version_count"],
        artistVersionCount: json["artist_version_count"],
        poolVersionCount: json["pool_version_count"],
        forumPostCount: json["forum_post_count"],
        commentCount: json["comment_count"],
        appealCount: json["appeal_count"],
        flagCount: json["flag_count"],
        positiveFeedbackCount: json["positive_feedback_count"],
        neutralFeedbackCount: json["neutral_feedback_count"],
        negativeFeedbackCount: json["negative_feedback_count"],
        uploadLimit: json["upload_limit"],
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        name: json["name"],
        level: json["level"],
        baseUploadLimit: json["base_upload_limit"],
        postUploadCount: json["post_upload_count"],
        postUpdateCount: json["post_update_count"],
        noteUpdateCount: json["note_update_count"],
        isBanned: json["is_banned"],
        canApprovePosts: json["can_approve_posts"],
        canUploadFree: json["can_upload_free"],
        levelString: json["level_string"],
        avatarId: json["avatar_id"],
      );

  Map<String, dynamic> toMap() => {
        "wiki_page_version_count": wikiPageVersionCount,
        "artist_version_count": artistVersionCount,
        "pool_version_count": poolVersionCount,
        "forum_post_count": forumPostCount,
        "comment_count": commentCount,
        "appeal_count": appealCount,
        "flag_count": flagCount,
        "positive_feedback_count": positiveFeedbackCount,
        "neutral_feedback_count": neutralFeedbackCount,
        "negative_feedback_count": negativeFeedbackCount,
        "upload_limit": uploadLimit,
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "name": name,
        "level": level,
        "base_upload_limit": baseUploadLimit,
        "post_upload_count": postUploadCount,
        "post_update_count": postUpdateCount,
        "note_update_count": noteUpdateCount,
        "is_banned": isBanned,
        "can_approve_posts": canApprovePosts,
        "can_upload_free": canUploadFree,
        "level_string": levelString,
        "avatar_id": avatarId,
      };
}
