// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Wiki _$$_WikiFromJson(Map<String, dynamic> json) => _$_Wiki(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      creatorId: json['creator_id'] as int,
      isLocked: json['is_locked'] as bool,
      updaterId: json['updater_id'] as int?,
      isDeleted: json['is_deleted'] as bool,
      otherNames: (json['other_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      creatorName: json['creator_name'] as String,
      categoryName: json['category_name'] as int,
    );

Map<String, dynamic> _$$_WikiToJson(_$_Wiki instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'creator_id': instance.creatorId,
      'is_locked': instance.isLocked,
      'updater_id': instance.updaterId,
      'is_deleted': instance.isDeleted,
      'other_names': instance.otherNames,
      'creator_name': instance.creatorName,
      'category_name': instance.categoryName,
    };
