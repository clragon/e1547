import 'dart:collection';
import 'dart:convert';

import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:meta/meta.dart';

class FollowList extends ListBase<String> {
  List<Follow> follows;

  FollowList({
    this.follows,
  }) {
    follows ??= [];
  }

  factory FollowList.from(FollowList list) {
    return FollowList(follows: list.follows);
  }

  factory FollowList.fromStrings(List<String> searches) {
    return FollowList(
        follows: searches.map((tags) => Follow(tags: tags)).toList());
  }

  factory FollowList.fromJson(String raw) =>
      FollowList.fromMap(json.decode(raw));

  String toJson() => json.encode(toMap());

  factory FollowList.fromMap(Map<String, dynamic> json) => FollowList(
        follows:
            List<Follow>.from(json["follows"].map((x) => Follow.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "follows": List<dynamic>.from(follows.map((x) => x.toMap())),
      };

  void write() {
    db.follows.value = Future.value(FollowList.from(this));
  }

  @override
  set length(int newLength) => follows.length = newLength;

  @override
  int get length => follows.length;

  @override
  String operator [](int index) => follows[index].tags;

  @override
  void operator []=(int index, String value) {
    follows[index] = Follow.fromString(value);
    write();
  }

  @override
  bool contains(Object tags) {
    return follows.any((element) => element.tags == tags);
  }

  @override
  void add(String tags) {
    follows.add(Follow(tags: tags));
    write();
  }

  @override
  void addAll(Iterable<String> searches) => searches.forEach(add);

  @override
  bool remove(Object tags) {
    bool removed = false;
    follows.removeWhere((element) {
      if (element.tags == tags) {
        removed = true;
        return true;
      }
      return false;
    });
    write();
    return removed;
  }

  @override
  String removeAt(int index) {
    remove(follows.elementAt(index));
    return super.removeAt(index);
  }

  @override
  void insert(int index, String tags) {
    follows.insert(index, Follow.fromString(tags));
    super.insert(index, tags);
  }

  void edit(Iterable<String> searches) {
    List<Follow> edited = [];
    for (String tags in searches) {
      Follow match = follows.firstWhere((follow) => follow.tags == tags,
          orElse: () => null);
      if (match != null) {
        edited.add(match);
      } else {
        edited.add(Follow.fromString(tags));
      }
    }
    follows = edited;
    write();
  }

  void updateAlias(int index, String alias) {
    if (follows.elementAt(index).updateAlias(alias)) {
      write();
    }
  }

  void updatePoolName(int index, Pool pool) {
    if (follows.elementAt(index).updatePoolName(pool)) {
      write();
    }
  }

  Future<bool> updateLatest(int index, Post post) async {
    if (await follows.elementAt(index).updateLatest(post)) {
      write();
      return true;
    }
    return false;
  }

  Future<bool> updateUnseen(int index, List<Post> posts) async {
    if (await follows.elementAt(index).updateUnseen(posts)) {
      write();
      return true;
    }
    return false;
  }
}

class Follow {
  String tags;
  String alias;
  bool notification;
  FollowStatus safe;
  FollowStatus unsafe;

  Follow({
    @required this.tags,
    this.alias,
    this.notification = false,
    this.safe,
    this.unsafe,
  }) {
    tags = sortTags(tags);
    safe ??= FollowStatus();
    unsafe ??= FollowStatus();
  }

  Future<FollowStatus> get status async =>
      (await db.host.value) != (await db.customHost.value) ? safe : unsafe;

  Future<DateTime> get updated async => (await status).updated;

  Future<String> get thumbnail async =>
      (await db.host.value) != (await db.customHost.value)
          ? safe.thumbnail
          : unsafe.thumbnail ?? safe.thumbnail;

  Future<int> get latest async => (await status).latest;

  String get title => alias ?? tagToTitle(tags);

  bool updateAlias(String alias) {
    if (this.alias != alias) {
      this.alias = alias;
      return true;
    }
    return false;
  }

  bool updatePoolName(Pool pool) {
    if (alias == null) {
      this.alias = tagToTitle(pool.name);
      return true;
    }
    return false;
  }

  Future<bool> updateLatest(Post post, {bool foreground = true}) async {
    bool updated = false;
    if (post != null) {
      FollowStatus status;
      FollowStatus other;

      if ((await db.host.value) != (await db.customHost.value)) {
        status = safe;
        other = unsafe;
      } else {
        status = unsafe;
        other = safe;
      }
      if (status.latest == null || status.latest < post.id) {
        status.latest = post.id;
        status.thumbnail = post.sample.value.url;
        updated = true;
      } else {
        if (status.thumbnail != post.sample.value.url) {
          status.thumbnail = post.sample.value.url;
          updated = true;
        }
      }
      if (status.updated == null ||
          DateTime.now().difference(status.updated).inHours > 1) {
        status.updated = DateTime.now();
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
    return updated;
  }

  Future<bool> updateUnseen(List<Post> posts) async {
    bool updated = false;
    if (posts.isNotEmpty) {
      FollowStatus status;
      FollowStatus other;

      if ((await db.host.value) != (await db.customHost.value)) {
        status = safe;
        other = unsafe;
      } else {
        status = unsafe;
        other = safe;
      }
      posts.sort((a, b) => b.id.compareTo(a.id));
      int limit = posts.indexWhere((element) => element.id == status.latest);
      if (limit == -1) {
        limit = posts.length;
      }
      updated = await updateLatest(posts.first, foreground: false);
      int length = posts.sublist(0, limit).length;
      if (status.unseen == null ||
          (length > status.unseen &&
              !(status.latest == other.latest && other.unseen == 0))) {
        status.unseen = length;
        updated = true;
      }
    }
    return updated;
  }

  factory Follow.fromString(String tags) => Follow(tags: tags);

  factory Follow.fromJson(String str) => Follow.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Follow.fromMap(Map<String, dynamic> json) => Follow(
        tags: json["tags"],
        alias: json["alias"],
        notification: json["notification"],
        safe: json["safe"] == null
            ? FollowStatus()
            : FollowStatus.fromJson(json['safe']),
        unsafe: json["unsafe"] == null
            ? FollowStatus()
            : FollowStatus.fromJson(json['unsafe']),
      );

  Map<String, dynamic> toMap() => {
        "tags": tags,
        "alias": alias,
        "notification": notification,
        "safe": safe == null ? null : safe.toJson(),
        "unsafe": unsafe == null ? null : unsafe.toJson(),
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
  int latest;
  int unseen;
  String thumbnail;
  DateTime updated;

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
