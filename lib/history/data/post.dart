import 'dart:convert';

import 'package:e1547/history/history.dart';

class PostHistoryEntry extends HistoryEntry {
  @override
  final DateTime visitedAt;
  final int id;
  final String? thumbnail;

  PostHistoryEntry({
    required this.visitedAt,
    required this.id,
    required this.thumbnail,
  });

  factory PostHistoryEntry.fromJson(String str) =>
      PostHistoryEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostHistoryEntry.fromMap(Map<String, dynamic> json) =>
      PostHistoryEntry(
        id: json["id"],
        visitedAt: DateTime.parse(json["visited_at"]),
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "visited_at": visitedAt.toIso8601String(),
        "thumbnail": thumbnail,
      };
}
