// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityImpl _$$IdentityImplFromJson(Map<String, dynamic> json) =>
    _$IdentityImpl(
      id: json['id'] as int,
      host: json['host'] as String,
      type: $enumDecode(_$ClientTypeEnumMap, json['type']),
      username: json['username'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$IdentityImplToJson(_$IdentityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'host': instance.host,
      'type': _$ClientTypeEnumMap[instance.type]!,
      'username': instance.username,
      'headers': instance.headers,
    };

const _$ClientTypeEnumMap = {
  ClientType.e621: 'e621',
  ClientType.danbooru: 'danbooru',
  ClientType.gelbooru: 'gelbooru',
  ClientType.moebooru: 'moebooru',
};

_$IdentityRequestImpl _$$IdentityRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$IdentityRequestImpl(
      host: json['host'] as String,
      type: $enumDecode(_$ClientTypeEnumMap, json['type']),
      username: json['username'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$IdentityRequestImplToJson(
        _$IdentityRequestImpl instance) =>
    <String, dynamic>{
      'host': instance.host,
      'type': _$ClientTypeEnumMap[instance.type]!,
      'username': instance.username,
      'headers': instance.headers,
    };
