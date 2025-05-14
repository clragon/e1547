// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatarId: (json['avatar_id'] as num?)?.toInt(),
      blacklistedTags: json['blacklisted_tags'] as String?,
      perPage: (json['per_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar_id': instance.avatarId,
      'blacklisted_tags': instance.blacklistedTags,
      'per_page': instance.perPage,
    };
