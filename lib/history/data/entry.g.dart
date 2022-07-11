// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_History _$$_HistoryFromJson(Map<String, dynamic> json) => _$_History(
      id: json['id'] as int,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$$_HistoryToJson(_$_History instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'thumbnails': instance.thumbnails,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };

_$_HistoryRequest _$$_HistoryRequestFromJson(Map<String, dynamic> json) =>
    _$_HistoryRequest(
      visitedAt: DateTime.parse(json['visited_at'] as String),
      link: json['link'] as String,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$$_HistoryRequestToJson(_$_HistoryRequest instance) =>
    <String, dynamic>{
      'visited_at': instance.visitedAt.toIso8601String(),
      'link': instance.link,
      'thumbnails': instance.thumbnails,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };
