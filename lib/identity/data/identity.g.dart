// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Identity _$IdentityFromJson(Map<String, dynamic> json) => _Identity(
  id: (json['id'] as num).toInt(),
  host: json['host'] as String,
  username: json['username'] as String?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$IdentityToJson(_Identity instance) => <String, dynamic>{
  'id': instance.id,
  'host': instance.host,
  'username': instance.username,
  'headers': instance.headers,
};

_IdentityRequest _$IdentityRequestFromJson(Map<String, dynamic> json) =>
    _IdentityRequest(
      host: json['host'] as String,
      username: json['username'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$IdentityRequestToJson(_IdentityRequest instance) =>
    <String, dynamic>{
      'host': instance.host,
      'username': instance.username,
      'headers': instance.headers,
    };
