// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityImpl _$$IdentityImplFromJson(Map<String, dynamic> json) =>
    _$IdentityImpl(
      id: (json['id'] as num).toInt(),
      host: json['host'] as String,
      username: json['username'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$IdentityImplToJson(_$IdentityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'host': instance.host,
      'username': instance.username,
      'headers': instance.headers,
    };

_$IdentityRequestImpl _$$IdentityRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$IdentityRequestImpl(
      host: json['host'] as String,
      username: json['username'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$IdentityRequestImplToJson(
        _$IdentityRequestImpl instance) =>
    <String, dynamic>{
      'host': instance.host,
      'username': instance.username,
      'headers': instance.headers,
    };
