// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      category: (json['category'] as num).toInt(),
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'count': instance.count,
      'category': instance.category,
    };
