import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/tag/tag.dart';

abstract final class E621Tag {
  static Tag fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Tag(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      count: pick('post_count').asIntOrThrow(),
      category: pick('category').asIntOrThrow(),
    ),
  );
}
