// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialsImpl _$$CredentialsImplFromJson(Map<String, dynamic> json) =>
    _$CredentialsImpl(
      username: json['username'] as String,
      password: json['apikey'] as String,
    );

Map<String, dynamic> _$$CredentialsImplToJson(_$CredentialsImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'apikey': instance.password,
    };
