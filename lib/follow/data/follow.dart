import 'dart:convert';

import 'package:collection/collection.dart';
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
  late FollowType type;
  late Map<String, FollowStatus> statuses;

  Follow({
    required this.tags,
    this.alias,
    FollowType? type,
    Map<String, FollowStatus>? status,
  }) {
    tags = sortTags(tags);
    this.statuses = status ?? {};
    this.type = type ?? FollowType.update;
  }

  String get name => alias ?? tagToTitle(tags);

  bool updateAlias(String alias) {
    if (this.alias != alias) {
      this.alias = alias;
      return true;
    }
    return false;
  }

  bool updatePool(Pool pool) {
    bool updated = false;
    if (alias == null) {
      alias = tagToTitle(pool.name);
      updated = true;
    }
    if (!pool.isActive && type != FollowType.bookmark) {
      type = FollowType.bookmark;
      updated = true;
    }
    return updated;
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

  Future<bool> updateLatest(String host, Post? post,
      {bool foreground = false}) async {
    bool updated = false;
    statuses.putIfAbsent(host, () => FollowStatus());
    FollowStatus? status = statuses[host]!;
    if (post != null) {
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
      if (foreground && status.unseen != 0) {
        status.unseen = 0;
        statuses.values
            .where((e) => status.latest == e.latest)
            .forEach((e) => e.unseen = 0);
        updated = true;
      }
    }
    if (await updateTimestamp(status)) {
      updated = true;
    }
    return updated;
  }

  Future<bool> updateUnseen(String host, List<Post> posts) async {
    bool updated = false;
    statuses.putIfAbsent(host, () => FollowStatus());
    FollowStatus? status = statuses[host]!;
    if (posts.isNotEmpty) {
      posts.sort((a, b) => b.id.compareTo(a.id));
      if (status.latest != null) {
        posts = posts.takeWhile((value) => value.id > status.latest!).toList();
      }
      if (posts.isNotEmpty) {
        updated = await updateLatest(host, posts.first);
      }
      int length = posts.length;
      if (status.unseen == null ||
          (statuses.entries.any((e) =>
              e.value != status &&
              e.value.unseen == 0 &&
              status.latest == e.value.latest))) {
        status.unseen = 0;
        updated = true;
      } else {
        status.unseen = length;
        updated = true;
      }
    }
    if (await updateTimestamp(status)) {
      updated = true;
    }
    return updated;
  }

  factory Follow.fromString(String tags) => Follow(tags: tags);

  factory Follow.fromJson(String str) => Follow.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Follow.fromMap(Map<String, dynamic> json) => Follow(
        tags: json['tags'],
        alias: json['alias'],
        status: json['statuses'] == null
            ? null
            : Map<String, FollowStatus>.from(json['statuses'].map(
                (key, value) => MapEntry(key, FollowStatus.fromMap(value)))),
        type: json['type'] == null
            ? null
            : FollowType.values
                .firstWhereOrNull((element) => element.name == json['type']),
      );

  Map<String, dynamic> toMap() => {
        'tags': tags,
        'alias': alias,
        'statuses': Map<String, dynamic>.from(
          statuses.map(
            (key, value) => MapEntry<String, dynamic>(key, value.toMap()),
          ),
        ),
        'type': type.name,
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
        latest: json['latest'],
        unseen: json['unseen'],
        thumbnail: json['thumbnail'],
        updated: DateTime.tryParse(json['updated'] ?? ''),
      );

  Map<String, dynamic> toMap() => {
        'latest': latest,
        'unseen': unseen,
        'thumbnail': thumbnail,
        'updated': updated?.toIso8601String(),
      };
}
