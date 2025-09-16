import 'package:e1547/traits/traits.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status.freezed.dart';
part 'status.g.dart';

@freezed
abstract class ClientSyncStatus with _$ClientSyncStatus {
  const factory ClientSyncStatus({DenyListSyncStatus? denyList}) =
      _ClientSyncStatus;

  factory ClientSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$ClientSyncStatusFromJson(json);
}
