// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Traits _$TraitsFromJson(Map<String, dynamic> json) => _Traits(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  denylist: (json['denylist'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  homeTags: json['home_tags'] as String,
  avatar: json['avatar'] as String?,
  perPage: (json['per_page'] as num?)?.toInt(),
);

Map<String, dynamic> _$TraitsToJson(_Traits instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'denylist': instance.denylist,
  'home_tags': instance.homeTags,
  'avatar': instance.avatar,
  'per_page': instance.perPage,
};

_TraitsRequest _$TraitsRequestFromJson(Map<String, dynamic> json) =>
    _TraitsRequest(
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

Map<String, dynamic> _$TraitsRequestToJson(_TraitsRequest instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'user_id': instance.userId,
      'denylist': instance.denylist,
      'home_tags': instance.homeTags,
      'avatar': instance.avatar,
      'per_page': instance.perPage,
    };
