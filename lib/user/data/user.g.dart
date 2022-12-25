// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_User _$$_UserFromJson(Map<String, dynamic> json) => _$_User(
      wikiPageVersionCount: json['wiki_page_version_count'] as int,
      artistVersionCount: json['artist_version_count'] as int,
      poolVersionCount: json['pool_version_count'] as int,
      forumPostCount: json['forum_post_count'] as int,
      commentCount: json['comment_count'] as int,
      flagCount: json['flag_count'] as int,
      favoriteCount: json['favorite_count'] as int,
      positiveFeedbackCount: json['positive_feedback_count'] as int,
      neutralFeedbackCount: json['neutral_feedback_count'] as int,
      negativeFeedbackCount: json['negative_feedback_count'] as int,
      uploadLimit: json['upload_limit'] as int,
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      level: json['level'] as int,
      baseUploadLimit: json['base_upload_limit'] as int,
      postUploadCount: json['post_upload_count'] as int,
      postUpdateCount: json['post_update_count'] as int,
      noteUpdateCount: json['note_update_count'] as int,
      isBanned: json['is_banned'] as bool,
      canApprovePosts: json['can_approve_posts'] as bool,
      canUploadFree: json['can_upload_free'] as bool,
      levelString: json['level_string'] as String,
      avatarId: json['avatar_id'] as int?,
    );

Map<String, dynamic> _$$_UserToJson(_$_User instance) =>
    <String, dynamic>{
      'wiki_page_version_count': instance.wikiPageVersionCount,
      'artist_version_count': instance.artistVersionCount,
      'pool_version_count': instance.poolVersionCount,
      'forum_post_count': instance.forumPostCount,
      'comment_count': instance.commentCount,
      'flag_count': instance.flagCount,
      'favorite_count': instance.favoriteCount,
      'positive_feedback_count': instance.positiveFeedbackCount,
      'neutral_feedback_count': instance.neutralFeedbackCount,
      'negative_feedback_count': instance.negativeFeedbackCount,
      'upload_limit': instance.uploadLimit,
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'level': instance.level,
      'base_upload_limit': instance.baseUploadLimit,
      'post_upload_count': instance.postUploadCount,
      'post_update_count': instance.postUpdateCount,
      'note_update_count': instance.noteUpdateCount,
      'is_banned': instance.isBanned,
      'can_approve_posts': instance.canApprovePosts,
      'can_upload_free': instance.canUploadFree,
      'level_string': instance.levelString,
      'avatar_id': instance.avatarId,
    };
