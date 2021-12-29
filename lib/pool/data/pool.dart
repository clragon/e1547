import 'dart:convert';

class Pool {
  Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.description,
    required this.isActive,
    required this.category,
    required this.isDeleted,
    required this.postIds,
    required this.creatorName,
    required this.postCount,
  });

  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int creatorId;
  String description;
  bool isActive;
  Category category;
  bool isDeleted;
  List<int> postIds;
  String creatorName;
  int postCount;

  factory Pool.fromJson(String str) => Pool.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Pool.fromMap(Map<String, dynamic> json) => Pool(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        creatorId: json["creator_id"],
        description: json["description"],
        isActive: json["is_active"],
        category: Category.values.asNameMap()[json["category"]]!,
        isDeleted: json["is_deleted"],
        postIds: List<int>.from(json["post_ids"].map((x) => x)),
        creatorName: json["creator_name"],
        postCount: json["post_count"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "creator_id": creatorId,
        "description": description,
        "is_active": isActive,
        "category": category.name,
        "is_deleted": isDeleted,
        "post_ids": List<dynamic>.from(postIds.map((x) => x)),
        "creator_name": creatorName,
        "post_count": postCount,
      };
}

enum Category { series, collection }
