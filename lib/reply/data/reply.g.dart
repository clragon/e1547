// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReplyImpl _$$ReplyImplFromJson(Map<String, dynamic> json) => _$ReplyImpl(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      body: json['body'] as String,
      creatorId: json['creator_id'] as int,
      topicId: json['topic_id'] as int,
      warning: json['warning'] == null
          ? null
          : ReplyWarning.fromJson(json['warning'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReplyImplToJson(_$ReplyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'body': instance.body,
      'creator_id': instance.creatorId,
      'topic_id': instance.topicId,
      'warning': instance.warning,
    };

_$ReplyWarningImpl _$$ReplyWarningImplFromJson(Map<String, dynamic> json) =>
    _$ReplyWarningImpl(
      type: $enumDecodeNullable(_$WarningTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$ReplyWarningImplToJson(_$ReplyWarningImpl instance) =>
    <String, dynamic>{
      'type': _$WarningTypeEnumMap[instance.type],
    };

const _$WarningTypeEnumMap = {
  WarningType.warning: 'warning',
  WarningType.record: 'record',
  WarningType.ban: 'ban',
};
