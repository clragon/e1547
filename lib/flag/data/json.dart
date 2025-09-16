import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/flag/flag.dart';

abstract final class E621PostFlag {
  static PostFlag fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => PostFlag(
      id: pick('id').asIntOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      postId: pick('post_id').asIntOrThrow(),
      reason: pick('reason').asStringOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      isResolved: pick('is_resolved').asBoolOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      isDeletion: pick('is_deletion').asBoolOrThrow(),
      type: PostFlagType.values.byName(pick('type').asStringOrThrow()),
    ),
  );
}
