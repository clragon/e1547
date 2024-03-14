// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPayloadImpl _$$NotificationPayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPayloadImpl(
      identity: json['identity'] as int,
      type: json['type'] as String,
      query: (json['query'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      id: json['id'] as int?,
    );

Map<String, dynamic> _$$NotificationPayloadImplToJson(
        _$NotificationPayloadImpl instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'type': instance.type,
      'query': instance.query,
      'id': instance.id,
    };
