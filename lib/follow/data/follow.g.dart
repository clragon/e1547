// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Follow _$$_FollowFromJson(Map<String, dynamic> json) => _$_Follow(
      tags: json['tags'] as String,
      alias: json['alias'] as String?,
      type: $enumDecodeNullable(_$FollowTypeEnumMap, json['type']) ??
          FollowType.update,
      statuses: (json['statuses'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, FollowStatus.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$_FollowToJson(_$_Follow instance) => <String, dynamic>{
      'tags': instance.tags,
      'alias': instance.alias,
      'type': _$FollowTypeEnumMap[instance.type],
      'statuses': instance.statuses,
    };

const _$FollowTypeEnumMap = {
  FollowType.update: 'update',
  FollowType.notify: 'notify',
  FollowType.bookmark: 'bookmark',
};

_$_FollowStatus _$$_FollowStatusFromJson(Map<String, dynamic> json) =>
    _$_FollowStatus(
      latest: json['latest'] as int?,
      unseen: json['unseen'] as int?,
      thumbnail: json['thumbnail'] as String?,
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$$_FollowStatusToJson(_$_FollowStatus instance) =>
    <String, dynamic>{
      'latest': instance.latest,
      'unseen': instance.unseen,
      'thumbnail': instance.thumbnail,
      'updated': instance.updated?.toIso8601String(),
    };
