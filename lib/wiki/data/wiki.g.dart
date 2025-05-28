// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WikiImpl _$$WikiImplFromJson(Map<String, dynamic> json) => _$WikiImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  otherNames: (json['other_names'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isLocked: json['is_locked'] as bool?,
);

Map<String, dynamic> _$$WikiImplToJson(_$WikiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'other_names': instance.otherNames,
      'is_locked': instance.isLocked,
    };
