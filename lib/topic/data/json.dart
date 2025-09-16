import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/topic/topic.dart';

abstract final class E621Topic {
  static Topic fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Topic(
      id: pick('id').asIntOrThrow(),
      creatorId: pick('creator_id').asIntOrThrow(),
      creator: pick('creator_name').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updaterId: pick('updater_id').asIntOrThrow(),
      updater: pick('updater_name').asStringOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrThrow(),
      title: pick('title').asStringOrThrow(),
      responseCount: pick('response_count').asIntOrThrow(),
      sticky: pick('is_sticky').asBoolOrThrow(),
      locked: pick('is_locked').asBoolOrThrow(),
      hidden: pick('is_hidden').asBoolOrThrow(),
      categoryId: pick('category_id').asIntOrThrow(),
    ),
  );
}
