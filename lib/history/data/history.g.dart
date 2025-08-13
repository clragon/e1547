// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_History _$HistoryFromJson(Map<String, dynamic> json) => _History(
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

Map<String, dynamic> _$HistoryToJson(_History instance) => <String, dynamic>{
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

_HistoryRequest _$HistoryRequestFromJson(Map<String, dynamic> json) =>
    _HistoryRequest(
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

Map<String, dynamic> _$HistoryRequestToJson(_HistoryRequest instance) =>
    <String, dynamic>{
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'category': _$HistoryCategoryEnumMap[instance.category]!,
      'type': _$HistoryTypeEnumMap[instance.type]!,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'thumbnails': instance.thumbnails,
    };
