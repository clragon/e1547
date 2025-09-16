import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/pool/pool.dart';

abstract final class E621Pool {
  static Pool fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Pool(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      description: pick('description').asStringOrThrow(),
      postIds: pick('post_ids').asListOrThrow((pick) => pick.asIntOrThrow()),
      postCount: pick('post_count').asIntOrThrow(),
      active: pick('is_active').asBoolOrThrow(),
    ),
  );
}
