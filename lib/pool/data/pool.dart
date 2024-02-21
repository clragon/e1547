import 'package:freezed_annotation/freezed_annotation.dart';

part 'pool.freezed.dart';
part 'pool.g.dart';

@freezed
class Pool with _$Pool {
  const factory Pool({
    required int id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String description,
    required List<int> postIds,
    required int postCount,
    required PoolActivity? activity,
  }) = _Pool;

  factory Pool.fromJson(dynamic json) => _$PoolFromJson(json);
}

@freezed
class PoolActivity with _$PoolActivity {
  const factory PoolActivity({
    required bool isActive,
  }) = _PoolActivity;

  factory PoolActivity.fromJson(dynamic json) => _$PoolActivityFromJson(json);
}
