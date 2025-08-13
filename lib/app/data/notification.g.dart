// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) =>
    _NotificationPayload(
      identity: (json['identity'] as num).toInt(),
      type: json['type'] as String,
      query: (json['query'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotificationPayloadToJson(
  _NotificationPayload instance,
) => <String, dynamic>{
  'identity': instance.identity,
  'type': instance.type,
  'query': instance.query,
  'id': instance.id,
};
