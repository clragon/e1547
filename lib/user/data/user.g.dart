// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatarId: (json['avatar_id'] as num?)?.toInt(),
      about: json['about'] == null ? null : UserAbout.fromJson(json['about']),
      stats: json['stats'] == null ? null : UserStats.fromJson(json['stats']),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar_id': instance.avatarId,
      'about': instance.about,
      'stats': instance.stats,
    };

_$UserAboutImpl _$$UserAboutImplFromJson(Map<String, dynamic> json) =>
    _$UserAboutImpl(
      bio: json['bio'] as String?,
      comission: json['comission'] as String?,
    );

Map<String, dynamic> _$$UserAboutImplToJson(_$UserAboutImpl instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'comission': instance.comission,
    };

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
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

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'level_string': instance.levelString,
      'favorite_count': instance.favoriteCount,
      'post_update_count': instance.postUpdateCount,
      'post_upload_count': instance.postUploadCount,
      'forum_post_count': instance.forumPostCount,
      'comment_count': instance.commentCount,
    };
