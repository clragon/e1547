import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';

enum FollowType {
  update,
  notify,
  bookmark,
}

class Follow {
  String tags;
  String? alias;
  late FollowStatus safe;
  late FollowStatus unsafe;
  late FollowType type;

  Follow({
    required this.tags,
    this.alias,
    FollowType? type,
    FollowStatus? safe,
    FollowStatus? unsafe,
  }) {
    tags = sortTags(tags);
    this.safe = safe ?? FollowStatus();
    this.unsafe = unsafe ?? FollowStatus();
    this.type = type ?? FollowType.update;
  }

  FollowStatus get status => client.isSafe ? safe : unsafe;

  DateTime? get updated => status.updated;

  String? get thumbnail => status.thumbnail;

  int? get latest => status.latest;

  String get title => alias ?? tagToTitle(tags);

  bool updateAlias(String alias) {
    if (this.alias != alias) {
      this.alias = alias;
      return true;
    }
    return false;
  }

  bool updatePool(Pool pool) {
    if (alias == null) {
      this.alias = tagToTitle(pool.name);
      return true;
    }
    if (!pool.isActive && type != FollowType.bookmark) {
      type = FollowType.bookmark;
      return true;
    }
    return false;
  }

  Future<bool> updateTimestamp(FollowStatus status) async {
    bool updated = false;
    if (status.updated == null ||
        DateTime.now().difference(status.updated!).inHours > 1) {
      status.updated = DateTime.now();
      updated = true;
    }
    return updated;
  }

  Future<bool> ensureCooldown() async => updateTimestamp(status);

  Future<bool> updateLatest(Post? post, {bool foreground = false}) async {
    bool updated = false;
    if (post != null) {
      FollowStatus? status;
      FollowStatus? other;

      if (client.isSafe) {
        status = safe;
        other = unsafe;
      } else {
        status = unsafe;
        other = safe;
      }
      if (status.latest == null || status.latest! < post.id) {
        status.latest = post.id;
        status.thumbnail = post.sample.url;
        updated = true;
      } else {
        if (status.thumbnail != post.sample.url) {
          status.thumbnail = post.sample.url;
          updated = true;
        }
      }
      if (await updateTimestamp(status)) {
        updated = true;
      }
      if (foreground && status.unseen != 0) {
        status.unseen = 0;
        if (status.latest == other.latest) {
          other.unseen = 0;
        }
        updated = true;
      }
    }
    if (await ensureCooldown()) {
      updated = true;
    }
    return updated;
  }

  Future<bool> updateUnseen(List<Post> posts) async {
    bool updated = false;
    if (posts.isNotEmpty) {
      FollowStatus? status;
      FollowStatus? other;

      if (client.isSafe) {
        status = safe;
        other = unsafe;
      } else {
        status = unsafe;
        other = safe;
      }
      posts.sort((a, b) => b.id.compareTo(a.id));
      if (status.latest != null) {
        posts = posts.takeWhile((value) => value.id > status!.latest!).toList();
      }
      if (posts.isNotEmpty) {
        updated = await updateLatest(posts.first);
      }
      int length = posts.length;
      if (status.unseen != null) {
        if ((length > status.unseen! &&
            !(status.latest == other.latest && other.unseen == 0))) {
          status.unseen = length;
          updated = true;
        }
      } else {
        status.unseen = 0;
        updated = true;
      }
    }
    if (await ensureCooldown()) {
      updated = true;
    }
    return updated;
  }

  factory Follow.fromString(String tags) => Follow(tags: tags);

  factory Follow.fromJson(String str) => Follow.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Follow.fromMap(Map<String, dynamic> json) => Follow(
        tags: json["tags"],
        alias: json["alias"],
        safe: json["safe"] == null
            ? FollowStatus()
            : FollowStatus.fromJson(json['safe']),
        unsafe: json["unsafe"] == null
            ? FollowStatus()
            : FollowStatus.fromJson(json['unsafe']),
        type: json['type'] == null
            ? FollowType.update
            : FollowType.values.firstWhereOrNull(
                (element) => element.toString() == json['type']),
      );

  Map<String, dynamic> toMap() => {
        "tags": tags,
        "alias": alias,
        "safe": safe.toJson(),
        "unsafe": unsafe.toJson(),
        "type": type.toString(),
      };

  @override
  bool operator ==(dynamic other) {
    if (other is Follow) {
      return tags == other.tags;
    }
    if (other is String) {
      return tags == other;
    }
    return false;
  }

  @override
  int get hashCode => toString().hashCode;
}

class FollowStatus {
  int? latest;
  int? unseen;
  String? thumbnail;
  DateTime? updated;

  FollowStatus({
    this.latest,
    this.unseen,
    this.thumbnail,
    this.updated,
  });

  factory FollowStatus.fromJson(String str) =>
      FollowStatus.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FollowStatus.fromMap(Map<String, dynamic> json) => FollowStatus(
        latest: json["latest"],
        unseen: json["unseen"],
        thumbnail: json["thumbnail"],
        updated: DateTime.tryParse(json['updated'] ?? ''),
      );

  Map<String, dynamic> toMap() => {
        "latest": latest,
        "unseen": unseen,
        "thumbnail": thumbnail,
        "updated": updated?.toIso8601String(),
      };
}
