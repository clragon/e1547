import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/shared/shared.dart';

abstract final class E621Comment {
  static Comment fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Comment(
      id: pick('id').asIntOrThrow(),
      postId: pick('post_id').asIntOrThrow(),
      body: pick('body').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creatorName: pick('creator_name').asStringOrThrow(),
      vote: VoteInfo(score: pick('score').asIntOrThrow()),
      warning: pick(
        'warning_type',
      ).letOrNull((pick) => WarningType.values.asNameMap()[pick.asString()]!),
      hidden: pick('is_hidden').asBoolOrThrow(),
    ),
  );
}
