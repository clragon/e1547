import 'dart:convert';

class PostData {
  PostData({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.file,
    this.preview,
    this.sample,
    this.score,
    this.tags,
    this.lockedTags,
    this.changeSeq,
    this.flags,
    this.rating,
    this.favCount,
    this.sources,
    this.pools,
    this.relationships,
    this.approverId,
    this.uploaderId,
    this.description,
    this.commentCount,
    this.isFavorited,
    this.hasNotes,
    this.duration,
  });

  int id;
  DateTime createdAt;
  DateTime updatedAt;
  PostSourceFile file;
  PostPreviewFile preview;
  PostSampleFile sample;
  Score score;
  Tags tags;
  List<String> lockedTags;
  int changeSeq;
  Flags flags;
  Rating rating;
  int favCount;
  List<String> sources;
  List<int> pools;
  Relationships relationships;
  int approverId;
  int uploaderId;
  String description;
  int commentCount;
  bool isFavorited;
  bool hasNotes;
  double duration;

  factory PostData.fromJson(String str) => PostData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  PostData.fromMap(Map<String, dynamic> json) {
    id = json["id"];
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt =
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]);
    file = PostSourceFile.fromMap(json["file"]);
    preview = PostPreviewFile.fromMap(json["preview"]);
    sample = PostSampleFile.fromMap(json["sample"]);
    score = Score.fromMap(json["score"]);
    tags = Tags.fromMap(json["tags"]);
    lockedTags = List<String>.from(json["locked_tags"].map((x) => x));
    changeSeq = json["change_seq"];
    flags = Flags.fromMap(json["flags"]);
    rating = ratingValues.map[json["rating"]];
    favCount = json["fav_count"];
    sources = List<String>.from(json["sources"].map((x) => x));
    pools = List<int>.from(json["pools"].map((x) => x));
    relationships = Relationships.fromMap(json["relationships"]);
    approverId = json["approver_id"] == null ? null : json["approver_id"];
    uploaderId = json["uploader_id"];
    description = json["description"];
    commentCount = json["comment_count"];
    isFavorited = json["is_favorited"];
    hasNotes = json["has_notes"];
    duration = json["duration"] == null ? null : json["duration"].toDouble();
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "file": file.toMap(),
        "preview": preview.toMap(),
        "sample": sample.toMap(),
        "score": score.toMap(),
        "tags": tags.toMap(),
        "locked_tags": List<dynamic>.from(lockedTags.map((x) => x)),
        "change_seq": changeSeq,
        "flags": flags.toMap(),
        "rating": ratingValues.reverse[rating],
        "fav_count": favCount,
        "sources": List<dynamic>.from(sources.map((x) => x)),
        "pools": List<dynamic>.from(pools.map((x) => x)),
        "relationships": relationships.toMap(),
        "approver_id": approverId == null ? null : approverId,
        "uploader_id": uploaderId,
        "description": description,
        "comment_count": commentCount,
        "is_favorited": isFavorited,
        "has_notes": hasNotes,
        "duration": duration == null ? null : duration,
      };
}

abstract class PostFile {
  PostFile({
    this.width,
    this.height,
    this.url,
  });

  int width;
  int height;
  String url;

  String toJson();

  Map<String, dynamic> toMap();
}

class PostPreviewFile implements PostFile {
  PostPreviewFile({
    this.width,
    this.height,
    this.url,
  });

  int width;
  int height;
  String url;

  factory PostPreviewFile.fromJson(String str) =>
      PostPreviewFile.fromMap(json.decode(str));

  factory PostPreviewFile.fromMap(Map<String, dynamic> json) => PostPreviewFile(
        width: json["width"],
        height: json["height"],
        url: json["url"],
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "url": url,
      };
}

class PostSourceFile implements PostFile {
  PostSourceFile({
    this.width,
    this.height,
    this.ext,
    this.size,
    this.md5,
    this.url,
  });

  int width;
  int height;
  String ext;
  int size;
  String md5;
  String url;

  factory PostSourceFile.fromJson(String str) =>
      PostSourceFile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostSourceFile.fromMap(Map<String, dynamic> json) => PostSourceFile(
        width: json["width"],
        height: json["height"],
        ext: json["ext"],
        size: json["size"],
        md5: json["md5"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "ext": ext,
        "size": size,
        "md5": md5,
        "url": url,
      };
}

class PostSampleFile implements PostFile {
  PostSampleFile({
    this.has,
    this.height,
    this.width,
    this.url,
  });

  bool has;
  int height;
  int width;
  String url;

  factory PostSampleFile.fromJson(String str) =>
      PostSampleFile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostSampleFile.fromMap(Map<String, dynamic> json) => PostSampleFile(
        has: json["has"],
        height: json["height"],
        width: json["width"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "has": has,
        "height": height,
        "width": width,
        "url": url,
      };
}

class Flags {
  Flags({
    this.pending,
    this.flagged,
    this.noteLocked,
    this.statusLocked,
    this.ratingLocked,
    this.deleted,
  });

  bool pending;
  bool flagged;
  bool noteLocked;
  bool statusLocked;
  bool ratingLocked;
  bool deleted;

  factory Flags.fromJson(String str) => Flags.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Flags.fromMap(Map<String, dynamic> json) => Flags(
        pending: json["pending"],
        flagged: json["flagged"],
        noteLocked: json["note_locked"],
        statusLocked: json["status_locked"],
        ratingLocked: json["rating_locked"],
        deleted: json["deleted"],
      );

  Map<String, dynamic> toMap() => {
        "pending": pending,
        "flagged": flagged,
        "note_locked": noteLocked,
        "status_locked": statusLocked,
        "rating_locked": ratingLocked,
        "deleted": deleted,
      };
}

enum Rating { E, S, Q }

final ratingValues = EnumValues({"e": Rating.E, "q": Rating.Q, "s": Rating.S});

class Relationships {
  Relationships({
    this.parentId,
    this.hasChildren,
    this.hasActiveChildren,
    this.children,
  });

  int parentId;
  bool hasChildren;
  bool hasActiveChildren;
  List<int> children;

  factory Relationships.fromJson(String str) =>
      Relationships.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Relationships.fromMap(Map<String, dynamic> json) => Relationships(
        parentId: json["parent_id"] == null ? null : json["parent_id"],
        hasChildren: json["has_children"],
        hasActiveChildren: json["has_active_children"],
        children: List<int>.from(json["children"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "parent_id": parentId == null ? null : parentId,
        "has_children": hasChildren,
        "has_active_children": hasActiveChildren,
        "children": List<dynamic>.from(children.map((x) => x)),
      };
}

class Score {
  Score({
    this.up,
    this.down,
    this.total,
  });

  int up;
  int down;
  int total;

  factory Score.fromJson(String str) => Score.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Score.fromMap(Map<String, dynamic> json) => Score(
        up: json["up"],
        down: json["down"],
        total: json["total"],
      );

  Map<String, dynamic> toMap() => {
        "up": up,
        "down": down,
        "total": total,
      };
}

class Tags {
  Tags({
    this.general,
    this.species,
    this.character,
    this.copyright,
    this.artist,
    this.invalid,
    this.lore,
    this.meta,
  });

  List<String> general;
  List<String> species;
  List<String> character;
  List<String> copyright;
  List<String> artist;
  List<String> invalid;
  List<String> lore;
  List<String> meta;

  factory Tags.fromJson(String str) => Tags.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Tags.fromMap(Map<String, dynamic> json) => Tags(
        general: List<String>.from(json["general"].map((x) => x)),
        species: List<String>.from(json["species"].map((x) => x)),
        character: List<String>.from(json["character"].map((x) => x)),
        copyright: List<String>.from(json["copyright"].map((x) => x)),
        artist: List<String>.from(json["artist"].map((x) => x)),
        invalid: List<String>.from(json["invalid"].map((x) => x)),
        lore: List<String>.from(json["lore"].map((x) => x)),
        meta: List<String>.from(json["meta"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "general": List<dynamic>.from(general.map((x) => x)),
        "species": List<dynamic>.from(species.map((x) => x)),
        "character": List<dynamic>.from(character.map((x) => x)),
        "copyright": List<dynamic>.from(copyright.map((x) => x)),
        "artist": List<dynamic>.from(artist.map((x) => x)),
        "invalid": List<dynamic>.from(invalid.map((x) => x)),
        "lore": List<dynamic>.from(lore.map((x) => x)),
        "meta": List<dynamic>.from(meta.map((x) => x)),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
