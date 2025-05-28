// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TraitsImpl _$$TraitsImplFromJson(Map<String, dynamic> json) => _$TraitsImpl(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  denylist: (json['denylist'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  homeTags: json['home_tags'] as String,
  avatar: json['avatar'] as String?,
  perPage: (json['per_page'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TraitsImplToJson(_$TraitsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'denylist': instance.denylist,
      'home_tags': instance.homeTags,
      'avatar': instance.avatar,
      'per_page': instance.perPage,
    };

_$TraitsRequestImpl _$$TraitsRequestImplFromJson(Map<String, dynamic> json) =>
    _$TraitsRequestImpl(
      identity: (json['identity'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      denylist:
          (json['denylist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      homeTags: json['home_tags'] as String? ?? '',
      avatar: json['avatar'] as String?,
      perPage: (json['per_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TraitsRequestImplToJson(_$TraitsRequestImpl instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'user_id': instance.userId,
      'denylist': instance.denylist,
      'home_tags': instance.homeTags,
      'avatar': instance.avatar,
      'per_page': instance.perPage,
    };
