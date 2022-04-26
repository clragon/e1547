import 'dart:convert';

import 'package:e1547/history/history.dart';

class TagHistoryEntry extends HistoryEntry {
  @override
  final DateTime visitedAt;
  final String tags;
  final String? alias;
  final List<String> thumbnails;

  TagHistoryEntry({
    required this.visitedAt,
    required this.tags,
    required this.thumbnails,
    this.alias,
  });

  factory TagHistoryEntry.fromJson(String str) =>
      TagHistoryEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TagHistoryEntry.fromMap(Map<String, dynamic> json) => TagHistoryEntry(
        visitedAt: DateTime.parse(json["visited_at"]),
        tags: json["tags"],
        alias: json["alias"],
        thumbnails: List<String>.from(json["thumbnails"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "visited_at": visitedAt.toIso8601String(),
        "tags": tags,
        "alias": alias,
        "thumbnails": thumbnails,
      };
}
