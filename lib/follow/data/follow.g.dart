// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FollowImpl _$$FollowImplFromJson(Map<String, dynamic> json) => _$FollowImpl(
  id: (json['id'] as num).toInt(),
  tags: json['tags'] as String,
  title: json['title'] as String?,
  alias: json['alias'] as String?,
  type: $enumDecode(_$FollowTypeEnumMap, json['type']),
  latest: (json['latest'] as num?)?.toInt(),
  unseen: (json['unseen'] as num?)?.toInt(),
  thumbnail: json['thumbnail'] as String?,
  updated: json['updated'] == null
      ? null
      : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$$FollowImplToJson(_$FollowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tags': instance.tags,
      'title': instance.title,
      'alias': instance.alias,
      'type': _$FollowTypeEnumMap[instance.type]!,
      'latest': instance.latest,
      'unseen': instance.unseen,
      'thumbnail': instance.thumbnail,
      'updated': instance.updated?.toIso8601String(),
    };

const _$FollowTypeEnumMap = {
  FollowType.update: 'update',
  FollowType.notify: 'notify',
  FollowType.bookmark: 'bookmark',
};

_$FollowRequestImpl _$$FollowRequestImplFromJson(Map<String, dynamic> json) =>
    _$FollowRequestImpl(
      tags: json['tags'] as String,
      title: json['title'] as String?,
      alias: json['alias'] as String?,
      type:
          $enumDecodeNullable(_$FollowTypeEnumMap, json['type']) ??
          FollowType.update,
    );

Map<String, dynamic> _$$FollowRequestImplToJson(_$FollowRequestImpl instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'title': instance.title,
      'alias': instance.alias,
      'type': _$FollowTypeEnumMap[instance.type]!,
    };

_$FollowUpdateImpl _$$FollowUpdateImplFromJson(Map<String, dynamic> json) =>
    _$FollowUpdateImpl(
      id: (json['id'] as num).toInt(),
      tags: json['tags'] as String?,
      title: json['title'] as String?,
      type: $enumDecodeNullable(_$FollowTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$FollowUpdateImplToJson(_$FollowUpdateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tags': instance.tags,
      'title': instance.title,
      'type': _$FollowTypeEnumMap[instance.type],
    };
