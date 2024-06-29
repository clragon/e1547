// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoolImpl _$$PoolImplFromJson(Map<String, dynamic> json) => _$PoolImpl(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String,
      postIds:
          (json['post_ids'] as List<dynamic>).map((e) => e as int).toList(),
      postCount: json['post_count'] as int,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$$PoolImplToJson(_$PoolImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'post_ids': instance.postIds,
      'post_count': instance.postCount,
      'active': instance.active,
    };
