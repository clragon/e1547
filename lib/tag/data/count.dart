import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:meta/meta.dart';

Map<String, int> countTags(List<String> tags, [Map<String, int> counts]) {
  counts ??= {};

  for (String tag in tags) {
    counts[tag] = (counts[tag] ?? 0) + 1;
  }

  return counts;
}

List<CountedTag> countTagsByPosts(List<Post> posts) {
  Map<String, Map<String, int>> categoryCounts = {};
  for (String category in categories.keys) {
    categoryCounts[category] = {};
  }
  List<CountedTag> counted = [];

  for (Post post in posts) {
    for (String category in categories.keys) {
      List<String> tags = post.tags.value[category];
      categoryCounts[category] = countTags(tags, categoryCounts[category]);
    }
  }

  for (MapEntry<String, Map<String, int>> category in categoryCounts.entries) {
    for (MapEntry<String, int> tags in category.value.entries) {
      counted.add(
          CountedTag(category: category.key, tag: tags.key, count: tags.value));
    }
  }

  return counted;
}

class CountedTag {
  final String category;
  final String tag;
  final int count;

  CountedTag({
    @required this.category,
    @required this.tag,
    @required this.count,
  });
}
