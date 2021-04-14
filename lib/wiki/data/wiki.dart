import 'dart:convert';

import 'package:meta/meta.dart';

class Wiki {
  Wiki({
    @required this.id,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.title,
    @required this.body,
    @required this.creatorId,
    @required this.isLocked,
    @required this.updaterId,
    @required this.isDeleted,
    @required this.otherNames,
    @required this.creatorName,
    @required this.categoryName,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  String title;
  String body;
  int creatorId;
  bool isLocked;
  int updaterId;
  bool isDeleted;
  List<String> otherNames;
  String creatorName;
  int categoryName;

  factory Wiki.fromJson(String str) => Wiki.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Wiki.fromMap(Map<String, dynamic> json) => Wiki(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        title: json["title"],
        body: json["body"],
        creatorId: json["creator_id"],
        isLocked: json["is_locked"],
        updaterId: json["updater_id"] == null ? null : json["updater_id"],
        isDeleted: json["is_deleted"],
        otherNames: List<String>.from(json["other_names"].map((x) => x)),
        creatorName: json["creator_name"],
        categoryName: json["category_name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "title": title,
        "body": body,
        "creator_id": creatorId,
        "is_locked": isLocked,
        "updater_id": updaterId == null ? null : updaterId,
        "is_deleted": isDeleted,
        "other_names": List<dynamic>.from(otherNames.map((x) => x)),
        "creator_name": creatorName,
        "category_name": categoryName,
      };
}
