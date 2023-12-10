import 'package:deep_pick/deep_pick.dart';
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

extension E621Pool on Pool {
  static Pool fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Pool(
          id: pick('id').asIntOrThrow(),
          name: pick('name').asStringOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          description: pick('description').asStringOrThrow(),
          postIds:
              pick('post_ids').asListOrThrow((pick) => pick.asIntOrThrow()),
          postCount: pick('post_count').asIntOrThrow(),
          activity: PoolActivity(
            isActive: pick('is_active').asBoolOrThrow(),
          ),
        ),
      );
}
