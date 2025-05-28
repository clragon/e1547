// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReplyImpl _$$ReplyImplFromJson(Map<String, dynamic> json) => _$ReplyImpl(
  id: (json['id'] as num).toInt(),
  creatorId: (json['creator_id'] as num).toInt(),
  creator: json['creator'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updaterId: (json['updater_id'] as num?)?.toInt(),
  updater: json['updater'] as String?,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  body: json['body'] as String,
  topicId: (json['topic_id'] as num).toInt(),
  warning: $enumDecodeNullable(_$WarningTypeEnumMap, json['warning']),
  hidden: json['hidden'] as bool,
);

Map<String, dynamic> _$$ReplyImplToJson(_$ReplyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'creator': instance.creator,
      'created_at': instance.createdAt.toIso8601String(),
      'updater_id': instance.updaterId,
      'updater': instance.updater,
      'updated_at': instance.updatedAt.toIso8601String(),
      'body': instance.body,
      'topic_id': instance.topicId,
      'warning': _$WarningTypeEnumMap[instance.warning],
      'hidden': instance.hidden,
    };

const _$WarningTypeEnumMap = {
  WarningType.warning: 'warning',
  WarningType.record: 'record',
  WarningType.ban: 'ban',
};
