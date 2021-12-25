import 'dart:convert';

class HistoryEntry {
  final DateTime visitedAt;
  final int postId;
  final String? thumbnail;

  HistoryEntry({
    required this.visitedAt,
    required this.postId,
    required this.thumbnail,
  });

  factory HistoryEntry.fromJson(String str) =>
      HistoryEntry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HistoryEntry.fromMap(Map<String, dynamic> json) => HistoryEntry(
        postId: json["postId"],
        visitedAt: DateTime.parse(json["visited_at"]),
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toMap() => {
        "postId": postId,
        "visited_at": visitedAt.toIso8601String(),
        "thumbnail": thumbnail,
      };
}
