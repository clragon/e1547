// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Comment _$$_CommentFromJson(Map<String, dynamic> json) => _$_Comment(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      postId: json['post_id'] as int,
      creatorId: json['creator_id'] as int,
      body: json['body'] as String,
      score: json['score'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updaterId: json['updater_id'] as int,
      doNotBumpPost: json['do_not_bump_post'] as bool,
      isHidden: json['is_hidden'] as bool,
      isSticky: json['is_sticky'] as bool,
      warningType: json['warning_type'] as int?,
      warningUserId: json['warning_user_id'] as int?,
      creatorName: json['creator_name'] as String,
      updaterName: json['updater_name'] as String,
    );

Map<String, dynamic> _$$_CommentToJson(_$_Comment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'post_id': instance.postId,
      'creator_id': instance.creatorId,
      'body': instance.body,
      'score': instance.score,
      'updated_at': instance.updatedAt.toIso8601String(),
      'updater_id': instance.updaterId,
      'do_not_bump_post': instance.doNotBumpPost,
      'is_hidden': instance.isHidden,
      'is_sticky': instance.isSticky,
      'warning_type': instance.warningType,
      'warning_user_id': instance.warningUserId,
      'creator_name': instance.creatorName,
      'updater_name': instance.updaterName,
    };
