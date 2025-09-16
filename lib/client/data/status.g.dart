// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientSyncStatus _$ClientSyncStatusFromJson(Map<String, dynamic> json) =>
    _ClientSyncStatus(
      denyList: $enumDecodeNullable(
        _$DenyListSyncStatusEnumMap,
        json['deny_list'],
      ),
    );

Map<String, dynamic> _$ClientSyncStatusToJson(_ClientSyncStatus instance) =>
    <String, dynamic>{
      'deny_list': _$DenyListSyncStatusEnumMap[instance.denyList],
    };

const _$DenyListSyncStatusEnumMap = {
  DenyListSyncStatus.idle: 'idle',
  DenyListSyncStatus.loading: 'loading',
  DenyListSyncStatus.error: 'error',
};
