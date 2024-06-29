// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creatorId: json['creator_id'] as int,
      creatorName: json['creator_name'] as String,
      vote: json['vote'] == null
          ? null
          : VoteInfo.fromJson(json['vote'] as Map<String, dynamic>),
      warning: $enumDecodeNullable(_$WarningTypeEnumMap, json['warning']),
      hidden: json['hidden'] as bool,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'creator_id': instance.creatorId,
      'creator_name': instance.creatorName,
      'vote': instance.vote,
      'warning': _$WarningTypeEnumMap[instance.warning],
      'hidden': instance.hidden,
    };

const _$WarningTypeEnumMap = {
  WarningType.warning: 'warning',
  WarningType.record: 'record',
  WarningType.ban: 'ban',
};
