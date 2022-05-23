import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:e1547/interface/interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
@CopyWith()
class Post {
  final VoteStatus voteStatus;

  Post({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required PostSourceFile file,
    required this.preview,
    required this.sample,
    required this.score,
    required this.tags,
    required this.lockedTags,
    required this.changeSeq,
    required this.flags,
    required this.rating,
    required this.favCount,
    required this.sources,
    required this.pools,
    required this.relationships,
    required this.approverId,
    required this.uploaderId,
    required this.description,
    required this.commentCount,
    required this.isFavorited,
    required this.hasNotes,
    required this.duration,
    this.voteStatus = VoteStatus.unknown,
  }) : file = Platform.isIOS && file.ext == 'webm'
            ? file.copyWith(
                ext: 'mp4',
                url: file.url!.replaceAll('.webm', '.mp4'),
              )
            : file;

  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PostSourceFile file;
  final PostPreviewFile preview;
  final PostSampleFile sample;
  final Score score;
  final Map<String, List<String>> tags;
  final List<String>? lockedTags;
  final int? changeSeq;
  final Flags flags;
  final Rating rating;
  final int favCount;
  final List<String> sources;
  final List<int> pools;
  final Relationships relationships;
  final int? approverId;
  final int uploaderId;
  final String description;
  final int commentCount;
  final bool isFavorited;
  final bool hasNotes;
  final double? duration;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

mixin PostFile {
  abstract final int width;
  abstract final int height;
  abstract final String? url;
}

@JsonSerializable()
@CopyWith()
class PostPreviewFile with PostFile {
  PostPreviewFile({
    required this.width,
    required this.height,
    this.url,
  });

  @override
  final int width;
  @override
  final int height;
  @override
  final String? url;

  factory PostPreviewFile.fromJson(Map<String, dynamic> json) =>
      _$PostPreviewFileFromJson(json);

  Map<String, dynamic> toJson() => _$PostPreviewFileToJson(this);
}

@JsonSerializable()
@CopyWith()
class PostSampleFile with PostFile {
  PostSampleFile({
    required this.has,
    required this.height,
    required this.width,
    this.url,
  });

  final bool has;
  @override
  final int height;
  @override
  final int width;
  @override
  final String? url;

  factory PostSampleFile.fromJson(Map<String, dynamic> json) =>
      _$PostSampleFileFromJson(json);

  Map<String, dynamic> toJson() => _$PostSampleFileToJson(this);
}

@JsonSerializable()
@CopyWith()
class PostSourceFile with PostFile {
  PostSourceFile({
    required this.width,
    required this.height,
    required this.ext,
    required this.size,
    required this.md5,
    this.url,
  });

  @override
  final int width;
  @override
  final int height;
  final String ext;
  final int size;
  final String md5;
  @override
  final String? url;

  factory PostSourceFile.fromJson(Map<String, dynamic> json) =>
      _$PostSourceFileFromJson(json);

  Map<String, dynamic> toJson() => _$PostSourceFileToJson(this);
}

@JsonSerializable()
@CopyWith()
class Flags {
  Flags({
    required this.pending,
    required this.flagged,
    required this.noteLocked,
    required this.statusLocked,
    required this.ratingLocked,
    required this.deleted,
  });

  final bool pending;
  final bool flagged;
  final bool noteLocked;
  final bool statusLocked;
  final bool ratingLocked;
  final bool deleted;

  factory Flags.fromJson(Map<String, dynamic> json) => _$FlagsFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsToJson(this);
}

@JsonEnum()
enum Rating { s, e, q }

@JsonSerializable()
@CopyWith()
class Relationships {
  Relationships({
    required this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });

  final int? parentId;
  final bool hasChildren;
  final bool hasActiveChildren;
  final List<int> children;

  factory Relationships.fromJson(Map<String, dynamic> json) =>
      _$RelationshipsFromJson(json);

  Map<String, dynamic> toJson() => _$RelationshipsToJson(this);
}

@JsonSerializable()
@CopyWith()
class Score {
  Score({
    required this.up,
    required this.down,
    required this.total,
  });

  final int up;
  final int down;
  final int total;

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}
