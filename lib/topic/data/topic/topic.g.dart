// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Topic _$$_TopicFromJson(Map<String, dynamic> json) => _$_Topic(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int,
      updaterId: json['updater_id'] as int,
      title: json['title'] as String,
      responseCount: json['response_count'] as int,
      isSticky: json['is_sticky'] as bool,
      isLocked: json['is_locked'] as bool,
      isHidden: json['is_hidden'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryId: json['category_id'] as int,
    );

Map<String, dynamic> _$$_TopicToJson(_$_Topic instance) => <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'updater_id': instance.updaterId,
      'title': instance.title,
      'response_count': instance.responseCount,
      'is_sticky': instance.isSticky,
      'is_locked': instance.isLocked,
      'is_hidden': instance.isHidden,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'category_id': instance.categoryId,
    };
