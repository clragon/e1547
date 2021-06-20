import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';

Map<String, int> countTags(List<String> tags, [Map<String, int> counts]) {
  counts ??= {};

  for (String tag in tags) {
    counts[tag] = (counts[tag] ?? 0) + 1;
  }

  return counts;
}

Map<String, int> countTagsFromPosts(List<Post> posts) {
  Map<String, int> counts = {};

  for (Post post in posts) {
    List<List<String>> tags = categories.keys.map((e) => post.tags.value[e]);
    for (List<String> category in tags) {
      countTags(category, counts);
    }
  }
  return counts;
}
