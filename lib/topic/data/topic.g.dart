// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicImpl _$$TopicImplFromJson(Map<String, dynamic> json) => _$TopicImpl(
  id: (json['id'] as num).toInt(),
  creatorId: (json['creator_id'] as num).toInt(),
  creator: json['creator'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updaterId: (json['updater_id'] as num).toInt(),
  updater: json['updater'] as String,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  title: json['title'] as String,
  responseCount: (json['response_count'] as num).toInt(),
  sticky: json['sticky'] as bool,
  locked: json['locked'] as bool,
  hidden: json['hidden'] as bool,
  categoryId: (json['category_id'] as num).toInt(),
);

Map<String, dynamic> _$$TopicImplToJson(_$TopicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'creator': instance.creator,
      'created_at': instance.createdAt.toIso8601String(),
      'updater_id': instance.updaterId,
      'updater': instance.updater,
      'updated_at': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'response_count': instance.responseCount,
      'sticky': instance.sticky,
      'locked': instance.locked,
      'hidden': instance.hidden,
      'category_id': instance.categoryId,
    };
