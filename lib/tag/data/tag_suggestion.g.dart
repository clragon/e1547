// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
