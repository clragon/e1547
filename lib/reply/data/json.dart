import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/reply/reply.dart';

abstract final class E621Reply {
  static Reply fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Reply(
      id: pick('id').asIntOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creator: pick('creator_name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updaterId: pick('updater_id').asIntOrNull(),
      updater: pick('updater_name').asStringOrNull(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      body: pick('body').asStringOrThrow(),
      topicId: pick('topic_id').asIntOrThrow(),
      warning: pick(
        'warning_type',
      ).letOrNull((pick) => WarningType.values.asNameMap()[pick.asString()]!),
      hidden: pick('is_hidden').asBoolOrThrow(),
    ),
  );
}
