// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  avatarId: (json['avatar_id'] as num?)?.toInt(),
  about: json['about'] == null ? null : UserAbout.fromJson(json['about']),
  stats: json['stats'] == null ? null : UserStats.fromJson(json['stats']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_id': instance.avatarId,
  'about': instance.about,
  'stats': instance.stats,
};

_UserAbout _$UserAboutFromJson(Map<String, dynamic> json) => _UserAbout(
  bio: json['bio'] as String?,
  comission: json['comission'] as String?,
);

Map<String, dynamic> _$UserAboutToJson(_UserAbout instance) =>
    <String, dynamic>{'bio': instance.bio, 'comission': instance.comission};

_UserStats _$UserStatsFromJson(Map<String, dynamic> json) => _UserStats(
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  levelString: json['level_string'] as String?,
  favoriteCount: (json['favorite_count'] as num?)?.toInt(),
  postUpdateCount: (json['post_update_count'] as num?)?.toInt(),
  postUploadCount: (json['post_upload_count'] as num?)?.toInt(),
  forumPostCount: (json['forum_post_count'] as num?)?.toInt(),
  commentCount: (json['comment_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserStatsToJson(_UserStats instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'level_string': instance.levelString,
      'favorite_count': instance.favoriteCount,
      'post_update_count': instance.postUpdateCount,
      'post_upload_count': instance.postUploadCount,
      'forum_post_count': instance.forumPostCount,
      'comment_count': instance.commentCount,
    };
