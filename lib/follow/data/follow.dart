import 'package:collection/collection.dart';
import 'package:e1547/tag/tag.dart';

enum FollowType {
  update,
  notify,
  bookmark,
}

class Follow {
  final String tags;
  final String? alias;
  final FollowType type;
  final Map<String, FollowStatus> statuses;

  Follow({
    required String tags,
    this.alias,
    FollowType? type,
    Map<String, FollowStatus>? statuses,
  })  : tags = sortTags(tags),
        statuses = Map.unmodifiable(statuses ?? {}),
        type = type ?? FollowType.update;

  factory Follow.fromString(String tags) => Follow(tags: tags);

  Follow copyWith({
    String? tags,
    String? alias,
    Map<String, FollowStatus>? statuses,
    FollowType? type,
  }) =>
      Follow(
        tags: tags ?? this.tags,
        alias: alias ?? this.alias,
        statuses: statuses ?? this.statuses,
        type: type ?? this.type,
      );

  factory Follow.fromJson(Map<String, dynamic> json) => Follow(
        tags: json["tags"],
        alias: json["alias"] == null ? null : json["alias"],
        statuses: Map.from(json["statuses"]).map((k, v) =>
            MapEntry<String, FollowStatus>(k, FollowStatus.fromJson(v))),
        type: FollowType.values
            .firstWhereOrNull((element) => element.name == json['type']),
      );

  Map<String, dynamic> toJson() => {
        "tags": tags,
        "alias": alias,
        "statuses": Map.from(statuses)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "type": type.name,
      };
}

class FollowStatus {
  final int? latest;
  final int? unseen;
  final String? thumbnail;
  final DateTime? updated;

  FollowStatus({
    this.latest,
    this.unseen,
    this.thumbnail,
    this.updated,
  });

  FollowStatus copyWith({
    int? latest,
    int? unseen,
    String? thumbnail,
    DateTime? updated,
  }) =>
      FollowStatus(
        latest: latest ?? this.latest,
        unseen: unseen ?? this.unseen,
        thumbnail: thumbnail ?? this.thumbnail,
        updated: updated ?? this.updated,
      );

  factory FollowStatus.fromJson(Map<String, dynamic> json) => FollowStatus(
        latest: json["latest"],
        unseen: json["unseen"],
        thumbnail: json["thumbnail"],
        updated: DateTime.tryParse(json["updated"] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "latest": latest,
        "unseen": unseen,
        "thumbnail": thumbnail,
        "updated": updated?.toIso8601String(),
      };
}
