// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Follow _$FollowFromJson(Map<String, dynamic> json) => _Follow(
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

Map<String, dynamic> _$FollowToJson(_Follow instance) => <String, dynamic>{
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

_FollowRequest _$FollowRequestFromJson(Map<String, dynamic> json) =>
    _FollowRequest(
      tags: json['tags'] as String,
      title: json['title'] as String?,
      alias: json['alias'] as String?,
      type:
          $enumDecodeNullable(_$FollowTypeEnumMap, json['type']) ??
          FollowType.update,
    );

Map<String, dynamic> _$FollowRequestToJson(_FollowRequest instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'title': instance.title,
      'alias': instance.alias,
      'type': _$FollowTypeEnumMap[instance.type]!,
    };

_FollowUpdate _$FollowUpdateFromJson(Map<String, dynamic> json) =>
    _FollowUpdate(
      id: (json['id'] as num).toInt(),
      tags: json['tags'] as String?,
      title: json['title'] as String?,
      type: $enumDecodeNullable(_$FollowTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$FollowUpdateToJson(_FollowUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tags': instance.tags,
      'title': instance.title,
      'type': _$FollowTypeEnumMap[instance.type],
    };
