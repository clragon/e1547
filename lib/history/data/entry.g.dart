// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryImpl _$$HistoryImplFromJson(Map<String, dynamic> json) =>
    _$HistoryImpl(
      id: json['id'] as int,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$$HistoryImplToJson(_$HistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'thumbnails': instance.thumbnails,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };

_$HistoryRequestImpl _$$HistoryRequestImplFromJson(Map<String, dynamic> json) =>
    _$HistoryRequestImpl(
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$$HistoryRequestImplToJson(
        _$HistoryRequestImpl instance) =>
    <String, dynamic>{
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'thumbnails': instance.thumbnails,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };
