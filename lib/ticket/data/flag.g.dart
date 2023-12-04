// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostFlagImpl _$$PostFlagImplFromJson(Map<String, dynamic> json) =>
    _$PostFlagImpl(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      postId: json['post_id'] as int,
      reason: json['reason'] as String,
      creatorId: json['creator_id'] as int,
      isResolved: json['is_resolved'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeletion: json['is_deletion'] as bool,
      type: $enumDecode(_$PostFlagTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$PostFlagImplToJson(_$PostFlagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'post_id': instance.postId,
      'reason': instance.reason,
      'creator_id': instance.creatorId,
      'is_resolved': instance.isResolved,
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_deletion': instance.isDeletion,
      'type': _$PostFlagTypeEnumMap[instance.type]!,
    };

const _$PostFlagTypeEnumMap = {
  PostFlagType.flag: 'flag',
  PostFlagType.deletion: 'deletion',
};
