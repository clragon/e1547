import 'dart:convert';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class Comment with ChangeNotifier {
  VoteStatus voteStatus = VoteStatus.unknown;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Comment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updatedAt,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isHidden,
    required this.isSticky,
    this.warningType,
    this.warningUserId,
    required this.creatorName,
    required this.updaterName,
  });

  int id;
  DateTime createdAt;
  int postId;
  int creatorId;
  String body;
  int score;
  DateTime updatedAt;
  int updaterId;
  bool doNotBumpPost;
  bool isHidden;
  bool isSticky;
  String? warningType;
  int? warningUserId;
  String creatorName;
  String updaterName;

  factory Comment.fromJson(String str) => Comment.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Comment.fromMap(Map<String, dynamic> json) => Comment(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        postId: json["post_id"],
        creatorId: json["creator_id"],
        body: json["body"],
        score: json["score"],
        updatedAt: DateTime.parse(json["updated_at"]),
        updaterId: json["updater_id"],
        doNotBumpPost: json["do_not_bump_post"],
        isHidden: json["is_hidden"],
        isSticky: json["is_sticky"],
        warningType: json["warning_type"],
        warningUserId: json["warning_user_id"],
        creatorName: json["creator_name"],
        updaterName: json["updater_name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "post_id": postId,
        "creator_id": creatorId,
        "body": body,
        "score": score,
        "updated_at": updatedAt.toIso8601String(),
        "updater_id": updaterId,
        "do_not_bump_post": doNotBumpPost,
        "is_hidden": isHidden,
        "is_sticky": isSticky,
        "warning_type": warningType,
        "warning_user_id": warningUserId,
        "creator_name": creatorName,
        "updater_name": updaterName,
      };
}
