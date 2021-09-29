import 'dart:convert';

class Topic {
  Topic({
    required this.id,
    required this.creatorId,
    required this.updaterId,
    required this.title,
    required this.responseCount,
    required this.isSticky,
    required this.isLocked,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
  });

  int id;
  int creatorId;
  int updaterId;
  String title;
  int responseCount;
  bool isSticky;
  bool isLocked;
  bool isHidden;
  DateTime createdAt;
  DateTime updatedAt;
  int categoryId;

  factory Topic.fromJson(String str) => Topic.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        id: json["id"],
        creatorId: json["creator_id"],
        updaterId: json["updater_id"],
        title: json["title"],
        responseCount: json["response_count"],
        isSticky: json["is_sticky"],
        isLocked: json["is_locked"],
        isHidden: json["is_hidden"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        categoryId: json["category_id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "creator_id": creatorId,
        "updater_id": updaterId,
        "title": title,
        "response_count": responseCount,
        "is_sticky": isSticky,
        "is_locked": isLocked,
        "is_hidden": isHidden,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "category_id": categoryId,
      };
}
