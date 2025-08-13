// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credentials _$CredentialsFromJson(Map<String, dynamic> json) => _Credentials(
  username: json['username'] as String,
  password: json['apikey'] as String,
);

Map<String, dynamic> _$CredentialsToJson(_Credentials instance) =>
    <String, dynamic>{
      'username': instance.username,
      'apikey': instance.password,
    };
