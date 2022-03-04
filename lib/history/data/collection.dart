import 'dart:convert';

import 'package:e1547/history/history.dart';

class HistoryCollection {
  final List<PostHistoryEntry> posts;
  final List<TagHistoryEntry> tags;

  List<HistoryEntry> get entries => [
        ...posts,
        ...tags,
      ]..sort((a, b) => a.visitedAt.compareTo(b.visitedAt));

  HistoryCollection({
    required this.posts,
    required this.tags,
  });

  factory HistoryCollection.empty() {
    return HistoryCollection(posts: [], tags: []);
  }

  factory HistoryCollection.fromJson(String str) =>
      HistoryCollection.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HistoryCollection.fromMap(Map<String, dynamic> json) =>
      HistoryCollection(
        posts: List<PostHistoryEntry>.from(
            json["posts"].map((x) => PostHistoryEntry.fromMap(x))),
        tags: List<TagHistoryEntry>.from(
            json["tags"].map((x) => TagHistoryEntry.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "posts": List<dynamic>.from(posts.map((x) => x.toMap())),
        "tags": List<dynamic>.from(tags.map((x) => x.toMap())),
      };

  HistoryCollection copyWith({
    List<PostHistoryEntry>? posts,
    List<TagHistoryEntry>? tags,
  }) =>
      HistoryCollection(
        posts: posts ?? this.posts,
        tags: tags ?? this.tags,
      );
}
