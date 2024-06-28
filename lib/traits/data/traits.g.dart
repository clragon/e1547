// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TraitsImpl _$$TraitsImplFromJson(Map<String, dynamic> json) => _$TraitsImpl(
      id: json['id'] as int,
      denylist:
          (json['denylist'] as List<dynamic>).map((e) => e as String).toList(),
      homeTags: json['home_tags'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$TraitsImplToJson(_$TraitsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'denylist': instance.denylist,
      'home_tags': instance.homeTags,
      'avatar': instance.avatar,
    };

_$TraitsRequestImpl _$$TraitsRequestImplFromJson(Map<String, dynamic> json) =>
    _$TraitsRequestImpl(
      identity: json['identity'] as int,
      denylist: (json['denylist'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      homeTags: json['home_tags'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$TraitsRequestImplToJson(_$TraitsRequestImpl instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'denylist': instance.denylist,
      'home_tags': instance.homeTags,
      'avatar': instance.avatar,
    };
