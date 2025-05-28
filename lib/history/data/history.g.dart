// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryImpl _$$HistoryImplFromJson(Map<String, dynamic> json) =>
    _$HistoryImpl(
      id: (json['id'] as num).toInt(),
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      category: $enumDecode(_$HistoryCategoryEnumMap, json['category']),
      type: $enumDecode(_$HistoryTypeEnumMap, json['type']),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$HistoryImplToJson(_$HistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'category': _$HistoryCategoryEnumMap[instance.category]!,
      'type': _$HistoryTypeEnumMap[instance.type]!,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'thumbnails': instance.thumbnails,
    };

const _$HistoryCategoryEnumMap = {
  HistoryCategory.items: 'items',
  HistoryCategory.searches: 'searches',
};

const _$HistoryTypeEnumMap = {
  HistoryType.posts: 'posts',
  HistoryType.pools: 'pools',
  HistoryType.topics: 'topics',
  HistoryType.users: 'users',
  HistoryType.wikis: 'wikis',
};

_$HistoryRequestImpl _$$HistoryRequestImplFromJson(Map<String, dynamic> json) =>
    _$HistoryRequestImpl(
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      category: $enumDecode(_$HistoryCategoryEnumMap, json['category']),
      type: $enumDecode(_$HistoryTypeEnumMap, json['type']),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      thumbnails:
          (json['thumbnails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HistoryRequestImplToJson(
  _$HistoryRequestImpl instance,
) => <String, dynamic>{
  'visited_at': instance.visitedAt.toIso8601String(),
  'link': instance.link,
  'category': _$HistoryCategoryEnumMap[instance.category]!,
  'type': _$HistoryTypeEnumMap[instance.type]!,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'thumbnails': instance.thumbnails,
};
