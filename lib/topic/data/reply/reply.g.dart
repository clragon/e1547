// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Reply _$$_ReplyFromJson(Map<String, dynamic> json) => _$_Reply(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      body: json['body'] as String,
      creatorId: json['creator_id'] as int,
      updaterId: json['updater_id'] as int?,
      topicId: json['topic_id'] as int,
      isHidden: json['is_hidden'] as bool,
      warningType: json['warning_type'] as int?,
      warningUserId: json['warning_user_id'] as int?,
    );

Map<String, dynamic> _$$_ReplyToJson(_$_Reply instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'body': instance.body,
      'creator_id': instance.creatorId,
      'updater_id': instance.updaterId,
      'topic_id': instance.topicId,
      'is_hidden': instance.isHidden,
      'warning_type': instance.warningType,
      'warning_user_id': instance.warningUserId,
    };
