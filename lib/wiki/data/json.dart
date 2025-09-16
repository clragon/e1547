import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/wiki/wiki.dart';

abstract final class E621Wiki {
  static Wiki fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Wiki(
      id: pick('id').asIntOrThrow(),
      title: pick('title').asStringOrThrow(),
      body: pick('body').asStringOrThrow(),
      createdAt: pick('created_at').asDateTimeOrThrow(),
      updatedAt: pick('updated_at').asDateTimeOrNull(),
      otherNames: pick('other_names').asListOrNull((e) => e.asStringOrThrow()),
      isLocked: pick('is_locked').asBoolOrNull(),
    ),
  );
}
