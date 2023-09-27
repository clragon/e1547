// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientSyncStatusImpl _$$ClientSyncStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$ClientSyncStatusImpl(
      denyList:
          $enumDecodeNullable(_$DenyListSyncStatusEnumMap, json['deny_list']),
    );

Map<String, dynamic> _$$ClientSyncStatusImplToJson(
        _$ClientSyncStatusImpl instance) =>
    <String, dynamic>{
      'deny_list': _$DenyListSyncStatusEnumMap[instance.denyList],
    };

const _$DenyListSyncStatusEnumMap = {
  DenyListSyncStatus.idle: 'idle',
  DenyListSyncStatus.loading: 'loading',
  DenyListSyncStatus.error: 'error',
};
