// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoriesSearchImpl _$$HistoriesSearchImplFromJson(
        Map<String, dynamic> json) =>
    _$HistoriesSearchImpl(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      searchFilters: (json['search_filters'] as List<dynamic>)
          .map((e) => $enumDecode(_$HistorySearchFilterEnumMap, e))
          .toSet(),
      typeFilters: (json['type_filters'] as List<dynamic>)
          .map((e) => $enumDecode(_$HistoryTypeFilterEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$$HistoriesSearchImplToJson(
        _$HistoriesSearchImpl instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'search_filters': instance.searchFilters
          .map((e) => _$HistorySearchFilterEnumMap[e]!)
          .toList(),
      'type_filters': instance.typeFilters
          .map((e) => _$HistoryTypeFilterEnumMap[e]!)
          .toList(),
    };

const _$HistorySearchFilterEnumMap = {
  HistorySearchFilter.items: 'items',
  HistorySearchFilter.searches: 'searches',
};

const _$HistoryTypeFilterEnumMap = {
  HistoryTypeFilter.posts: 'posts',
  HistoryTypeFilter.pools: 'pools',
  HistoryTypeFilter.topics: 'topics',
  HistoryTypeFilter.users: 'users',
  HistoryTypeFilter.wikis: 'wikis',
};
