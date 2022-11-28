// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Tag _$$_TagFromJson(Map<String, dynamic> json) => _$_Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      postCount: json['post_count'] as int,
      relatedTags: json['related_tags'] as String,
      relatedTagsUpdatedAt:
          DateTime.parse(json['related_tags_updated_at'] as String),
      category: json['category'] as int,
      isLocked: json['is_locked'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$_TagToJson(_$_Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'post_count': instance.postCount,
      'related_tags': instance.relatedTags,
      'related_tags_updated_at':
          instance.relatedTagsUpdatedAt.toIso8601String(),
      'category': instance.category,
      'is_locked': instance.isLocked,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$_TagSuggestion _$$_TagSuggestionFromJson(Map<String, dynamic> json) =>
    _$_TagSuggestion(
      id: json['id'] as int,
      name: json['name'] as String,
      postCount: json['post_count'] as int,
      category: json['category'] as int,
      antecedentName: json['antecedent_name'] as String?,
    );

Map<String, dynamic> _$$_TagSuggestionToJson(_$_TagSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'post_count': instance.postCount,
      'category': instance.category,
      'antecedent_name': instance.antecedentName,
    };
