import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const Post._();

  const factory Post({
    required int id,
    required DateTime createdAt,
    required DateTime? updatedAt,
    @JsonKey(name: 'file') required PostSourceFile fileRaw,
    required PostPreviewFile preview,
    required PostSampleFile sample,
    required Score score,
    required Map<String, List<String>> tags,
    required List<String>? lockedTags,
    required int? changeSeq,
    required Flags flags,
    required Rating rating,
    required int favCount,
    required List<String> sources,
    required List<int> pools,
    required Relationships relationships,
    required int? approverId,
    required int uploaderId,
    required String description,
    required int commentCount,
    required bool isFavorited,
    required bool hasNotes,
    required double? duration,
    @JsonKey(ignore: true) @Default(VoteStatus.unknown) VoteStatus voteStatus,
  }) = _Post;

  factory Post.fromJson(dynamic json) => _$PostFromJson(json);

  PostSourceFile get file => Platform.isIOS && fileRaw.ext == 'webm'
      ? fileRaw.copyWith(
          ext: 'mp4',
          url: fileRaw.url!.replaceAll('.webm', '.mp4'),
        )
      : fileRaw;
}

@freezed
class PostPreviewFile with _$PostPreviewFile {
  const factory PostPreviewFile({
    required int width,
    required int height,
    required String? url,
  }) = _PostPreviewFile;

  factory PostPreviewFile.fromJson(dynamic json) =>
      _$PostPreviewFileFromJson(json);
}

@freezed
class PostSampleFile with _$PostSampleFile {
  const factory PostSampleFile({
    required bool has,
    required int height,
    required int width,
    required String? url,
  }) = _PostSampleFile;

  factory PostSampleFile.fromJson(dynamic json) =>
      _$PostSampleFileFromJson(json);
}

@freezed
class PostSourceFile with _$PostSourceFile {
  const factory PostSourceFile({
    required int width,
    required int height,
    required String ext,
    required int size,
    required String md5,
    required String? url,
  }) = _PostSourceFile;

  factory PostSourceFile.fromJson(dynamic json) =>
      _$PostSourceFileFromJson(json);
}

@freezed
class Flags with _$Flags {
  const factory Flags({
    required bool pending,
    required bool flagged,
    required bool noteLocked,
    required bool statusLocked,
    required bool ratingLocked,
    required bool deleted,
  }) = _Flags;

  factory Flags.fromJson(dynamic json) => _$FlagsFromJson(json);
}

@JsonEnum()
enum Rating { s, q, e }

@freezed
class Relationships with _$Relationships {
  const factory Relationships({
    required int? parentId,
    required bool hasChildren,
    required bool hasActiveChildren,
    required List<int> children,
  }) = _Relationships;

  factory Relationships.fromJson(dynamic json) => _$RelationshipsFromJson(json);
}

@freezed
class Score with _$Score {
  const factory Score({
    required int up,
    required int down,
    required int total,
  }) = _Score;

  factory Score.fromJson(dynamic json) => _$ScoreFromJson(json);
}
