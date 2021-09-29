import 'dart:convert';

class Reply {
  Reply({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.creatorId,
    required this.updaterId,
    required this.topicId,
    required this.isHidden,
    required this.warningType,
    required this.warningUserId,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  String body;
  int creatorId;
  int? updaterId;
  int topicId;
  bool isHidden;
  dynamic warningType;
  dynamic warningUserId;

  factory Reply.fromJson(String str) => Reply.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Reply.fromMap(Map<String, dynamic> json) => Reply(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        body: json["body"],
        creatorId: json["creator_id"],
        updaterId: json["updater_id"],
        topicId: json["topic_id"],
        isHidden: json["is_hidden"],
        warningType: json["warning_type"],
        warningUserId: json["warning_user_id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "body": body,
        "creator_id": creatorId,
        "updater_id": updaterId,
        "topic_id": topicId,
        "is_hidden": isHidden,
        "warning_type": warningType,
        "warning_user_id": warningUserId,
      };
}
