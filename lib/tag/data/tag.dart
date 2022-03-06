class Tag {
  Tag({
    required this.id,
    required this.name,
    required this.postCount,
    required this.relatedTags,
    required this.relatedTagsUpdatedAt,
    required this.category,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final int postCount;
  final String relatedTags;
  final DateTime relatedTagsUpdatedAt;
  final int category;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        postCount: json["post_count"],
        relatedTags: json["related_tags"],
        relatedTagsUpdatedAt: DateTime.parse(json["related_tags_updated_at"]),
        category: json["category"],
        isLocked: json["is_locked"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "post_count": postCount,
        "related_tags": relatedTags,
        "related_tags_updated_at": relatedTagsUpdatedAt.toIso8601String(),
        "category": category,
        "is_locked": isLocked,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class AutocompleteTag {
  AutocompleteTag({
    required this.id,
    required this.name,
    required this.postCount,
    required this.category,
    required this.antecedentName,
  });

  final int id;
  final String name;
  final int postCount;
  final int category;
  final String? antecedentName;

  factory AutocompleteTag.fromJson(Map<String, dynamic> json) =>
      AutocompleteTag(
        id: json["id"],
        name: json["name"],
        postCount: json["post_count"],
        category: json["category"],
        antecedentName: json["antecedent_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "post_count": postCount,
        "category": category,
        "antecedent_name": antecedentName,
      };
}
