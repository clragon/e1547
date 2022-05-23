// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostCWProxy {
  Post approverId(int? approverId);

  Post changeSeq(int? changeSeq);

  Post commentCount(int commentCount);

  Post createdAt(DateTime createdAt);

  Post description(String description);

  Post duration(double? duration);

  Post favCount(int favCount);

  Post file(PostSourceFile file);

  Post flags(Flags flags);

  Post hasNotes(bool hasNotes);

  Post id(int id);

  Post isFavorited(bool isFavorited);

  Post lockedTags(List<String>? lockedTags);

  Post pools(List<int> pools);

  Post preview(PostPreviewFile preview);

  Post rating(Rating rating);

  Post relationships(Relationships relationships);

  Post sample(PostSampleFile sample);

  Post score(Score score);

  Post sources(List<String> sources);

  Post tags(Map<String, List<String>> tags);

  Post updatedAt(DateTime? updatedAt);

  Post uploaderId(int uploaderId);

  Post voteStatus(VoteStatus voteStatus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Post(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Post(...).copyWith(id: 12, name: "My name")
  /// ````
  Post call({
    int? approverId,
    int? changeSeq,
    int? commentCount,
    DateTime? createdAt,
    String? description,
    double? duration,
    int? favCount,
    PostSourceFile? file,
    Flags? flags,
    bool? hasNotes,
    int? id,
    bool? isFavorited,
    List<String>? lockedTags,
    List<int>? pools,
    PostPreviewFile? preview,
    Rating? rating,
    Relationships? relationships,
    PostSampleFile? sample,
    Score? score,
    List<String>? sources,
    Map<String, List<String>>? tags,
    DateTime? updatedAt,
    int? uploaderId,
    VoteStatus? voteStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPost.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPost.copyWith.fieldName(...)`
class _$PostCWProxyImpl implements _$PostCWProxy {
  final Post _value;

  const _$PostCWProxyImpl(this._value);

  @override
  Post approverId(int? approverId) => this(approverId: approverId);

  @override
  Post changeSeq(int? changeSeq) => this(changeSeq: changeSeq);

  @override
  Post commentCount(int commentCount) => this(commentCount: commentCount);

  @override
  Post createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Post description(String description) => this(description: description);

  @override
  Post duration(double? duration) => this(duration: duration);

  @override
  Post favCount(int favCount) => this(favCount: favCount);

  @override
  Post file(PostSourceFile file) => this(file: file);

  @override
  Post flags(Flags flags) => this(flags: flags);

  @override
  Post hasNotes(bool hasNotes) => this(hasNotes: hasNotes);

  @override
  Post id(int id) => this(id: id);

  @override
  Post isFavorited(bool isFavorited) => this(isFavorited: isFavorited);

  @override
  Post lockedTags(List<String>? lockedTags) => this(lockedTags: lockedTags);

  @override
  Post pools(List<int> pools) => this(pools: pools);

  @override
  Post preview(PostPreviewFile preview) => this(preview: preview);

  @override
  Post rating(Rating rating) => this(rating: rating);

  @override
  Post relationships(Relationships relationships) =>
      this(relationships: relationships);

  @override
  Post sample(PostSampleFile sample) => this(sample: sample);

  @override
  Post score(Score score) => this(score: score);

  @override
  Post sources(List<String> sources) => this(sources: sources);

  @override
  Post tags(Map<String, List<String>> tags) => this(tags: tags);

  @override
  Post updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  Post uploaderId(int uploaderId) => this(uploaderId: uploaderId);

  @override
  Post voteStatus(VoteStatus voteStatus) => this(voteStatus: voteStatus);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Post(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Post(...).copyWith(id: 12, name: "My name")
  /// ````
  Post call({
    Object? approverId = const $CopyWithPlaceholder(),
    Object? changeSeq = const $CopyWithPlaceholder(),
    Object? commentCount = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? favCount = const $CopyWithPlaceholder(),
    Object? file = const $CopyWithPlaceholder(),
    Object? flags = const $CopyWithPlaceholder(),
    Object? hasNotes = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isFavorited = const $CopyWithPlaceholder(),
    Object? lockedTags = const $CopyWithPlaceholder(),
    Object? pools = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? relationships = const $CopyWithPlaceholder(),
    Object? sample = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? sources = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? uploaderId = const $CopyWithPlaceholder(),
    Object? voteStatus = const $CopyWithPlaceholder(),
  }) {
    return Post(
      approverId: approverId == const $CopyWithPlaceholder()
          ? _value.approverId
          // ignore: cast_nullable_to_non_nullable
          : approverId as int?,
      changeSeq: changeSeq == const $CopyWithPlaceholder()
          ? _value.changeSeq
          // ignore: cast_nullable_to_non_nullable
          : changeSeq as int?,
      commentCount:
          commentCount == const $CopyWithPlaceholder() || commentCount == null
              ? _value.commentCount
              // ignore: cast_nullable_to_non_nullable
              : commentCount as int,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as double?,
      favCount: favCount == const $CopyWithPlaceholder() || favCount == null
          ? _value.favCount
          // ignore: cast_nullable_to_non_nullable
          : favCount as int,
      file: file == const $CopyWithPlaceholder() || file == null
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as PostSourceFile,
      flags: flags == const $CopyWithPlaceholder() || flags == null
          ? _value.flags
          // ignore: cast_nullable_to_non_nullable
          : flags as Flags,
      hasNotes: hasNotes == const $CopyWithPlaceholder() || hasNotes == null
          ? _value.hasNotes
          // ignore: cast_nullable_to_non_nullable
          : hasNotes as bool,
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isFavorited:
          isFavorited == const $CopyWithPlaceholder() || isFavorited == null
              ? _value.isFavorited
              // ignore: cast_nullable_to_non_nullable
              : isFavorited as bool,
      lockedTags: lockedTags == const $CopyWithPlaceholder()
          ? _value.lockedTags
          // ignore: cast_nullable_to_non_nullable
          : lockedTags as List<String>?,
      pools: pools == const $CopyWithPlaceholder() || pools == null
          ? _value.pools
          // ignore: cast_nullable_to_non_nullable
          : pools as List<int>,
      preview: preview == const $CopyWithPlaceholder() || preview == null
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as PostPreviewFile,
      rating: rating == const $CopyWithPlaceholder() || rating == null
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as Rating,
      relationships:
          relationships == const $CopyWithPlaceholder() || relationships == null
              ? _value.relationships
              // ignore: cast_nullable_to_non_nullable
              : relationships as Relationships,
      sample: sample == const $CopyWithPlaceholder() || sample == null
          ? _value.sample
          // ignore: cast_nullable_to_non_nullable
          : sample as PostSampleFile,
      score: score == const $CopyWithPlaceholder() || score == null
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as Score,
      sources: sources == const $CopyWithPlaceholder() || sources == null
          ? _value.sources
          // ignore: cast_nullable_to_non_nullable
          : sources as List<String>,
      tags: tags == const $CopyWithPlaceholder() || tags == null
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as Map<String, List<String>>,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      uploaderId:
          uploaderId == const $CopyWithPlaceholder() || uploaderId == null
              ? _value.uploaderId
              // ignore: cast_nullable_to_non_nullable
              : uploaderId as int,
      voteStatus:
          voteStatus == const $CopyWithPlaceholder() || voteStatus == null
              ? _value.voteStatus
              // ignore: cast_nullable_to_non_nullable
              : voteStatus as VoteStatus,
    );
  }
}

extension $PostCopyWith on Post {
  /// Returns a callable class that can be used as follows: `instanceOfPost.copyWith(...)` or like so:`instanceOfPost.copyWith.fieldName(...)`.
  _$PostCWProxy get copyWith => _$PostCWProxyImpl(this);
}

abstract class _$PostPreviewFileCWProxy {
  PostPreviewFile height(int height);

  PostPreviewFile url(String? url);

  PostPreviewFile width(int width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostPreviewFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostPreviewFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostPreviewFile call({
    int? height,
    String? url,
    int? width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostPreviewFile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostPreviewFile.copyWith.fieldName(...)`
class _$PostPreviewFileCWProxyImpl implements _$PostPreviewFileCWProxy {
  final PostPreviewFile _value;

  const _$PostPreviewFileCWProxyImpl(this._value);

  @override
  PostPreviewFile height(int height) => this(height: height);

  @override
  PostPreviewFile url(String? url) => this(url: url);

  @override
  PostPreviewFile width(int width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostPreviewFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostPreviewFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostPreviewFile call({
    Object? height = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return PostPreviewFile(
      height: height == const $CopyWithPlaceholder() || height == null
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      width: width == const $CopyWithPlaceholder() || width == null
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int,
    );
  }
}

extension $PostPreviewFileCopyWith on PostPreviewFile {
  /// Returns a callable class that can be used as follows: `instanceOfPostPreviewFile.copyWith(...)` or like so:`instanceOfPostPreviewFile.copyWith.fieldName(...)`.
  _$PostPreviewFileCWProxy get copyWith => _$PostPreviewFileCWProxyImpl(this);
}

abstract class _$PostSampleFileCWProxy {
  PostSampleFile has(bool has);

  PostSampleFile height(int height);

  PostSampleFile url(String? url);

  PostSampleFile width(int width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostSampleFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostSampleFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostSampleFile call({
    bool? has,
    int? height,
    String? url,
    int? width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostSampleFile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostSampleFile.copyWith.fieldName(...)`
class _$PostSampleFileCWProxyImpl implements _$PostSampleFileCWProxy {
  final PostSampleFile _value;

  const _$PostSampleFileCWProxyImpl(this._value);

  @override
  PostSampleFile has(bool has) => this(has: has);

  @override
  PostSampleFile height(int height) => this(height: height);

  @override
  PostSampleFile url(String? url) => this(url: url);

  @override
  PostSampleFile width(int width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostSampleFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostSampleFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostSampleFile call({
    Object? has = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return PostSampleFile(
      has: has == const $CopyWithPlaceholder() || has == null
          ? _value.has
          // ignore: cast_nullable_to_non_nullable
          : has as bool,
      height: height == const $CopyWithPlaceholder() || height == null
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      width: width == const $CopyWithPlaceholder() || width == null
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int,
    );
  }
}

extension $PostSampleFileCopyWith on PostSampleFile {
  /// Returns a callable class that can be used as follows: `instanceOfPostSampleFile.copyWith(...)` or like so:`instanceOfPostSampleFile.copyWith.fieldName(...)`.
  _$PostSampleFileCWProxy get copyWith => _$PostSampleFileCWProxyImpl(this);
}

abstract class _$PostSourceFileCWProxy {
  PostSourceFile ext(String ext);

  PostSourceFile height(int height);

  PostSourceFile md5(String md5);

  PostSourceFile size(int size);

  PostSourceFile url(String? url);

  PostSourceFile width(int width);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostSourceFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostSourceFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostSourceFile call({
    String? ext,
    int? height,
    String? md5,
    int? size,
    String? url,
    int? width,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostSourceFile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostSourceFile.copyWith.fieldName(...)`
class _$PostSourceFileCWProxyImpl implements _$PostSourceFileCWProxy {
  final PostSourceFile _value;

  const _$PostSourceFileCWProxyImpl(this._value);

  @override
  PostSourceFile ext(String ext) => this(ext: ext);

  @override
  PostSourceFile height(int height) => this(height: height);

  @override
  PostSourceFile md5(String md5) => this(md5: md5);

  @override
  PostSourceFile size(int size) => this(size: size);

  @override
  PostSourceFile url(String? url) => this(url: url);

  @override
  PostSourceFile width(int width) => this(width: width);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostSourceFile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostSourceFile(...).copyWith(id: 12, name: "My name")
  /// ````
  PostSourceFile call({
    Object? ext = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? md5 = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
  }) {
    return PostSourceFile(
      ext: ext == const $CopyWithPlaceholder() || ext == null
          ? _value.ext
          // ignore: cast_nullable_to_non_nullable
          : ext as String,
      height: height == const $CopyWithPlaceholder() || height == null
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as int,
      md5: md5 == const $CopyWithPlaceholder() || md5 == null
          ? _value.md5
          // ignore: cast_nullable_to_non_nullable
          : md5 as String,
      size: size == const $CopyWithPlaceholder() || size == null
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      width: width == const $CopyWithPlaceholder() || width == null
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as int,
    );
  }
}

extension $PostSourceFileCopyWith on PostSourceFile {
  /// Returns a callable class that can be used as follows: `instanceOfPostSourceFile.copyWith(...)` or like so:`instanceOfPostSourceFile.copyWith.fieldName(...)`.
  _$PostSourceFileCWProxy get copyWith => _$PostSourceFileCWProxyImpl(this);
}

abstract class _$FlagsCWProxy {
  Flags deleted(bool deleted);

  Flags flagged(bool flagged);

  Flags noteLocked(bool noteLocked);

  Flags pending(bool pending);

  Flags ratingLocked(bool ratingLocked);

  Flags statusLocked(bool statusLocked);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Flags(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Flags(...).copyWith(id: 12, name: "My name")
  /// ````
  Flags call({
    bool? deleted,
    bool? flagged,
    bool? noteLocked,
    bool? pending,
    bool? ratingLocked,
    bool? statusLocked,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFlags.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFlags.copyWith.fieldName(...)`
class _$FlagsCWProxyImpl implements _$FlagsCWProxy {
  final Flags _value;

  const _$FlagsCWProxyImpl(this._value);

  @override
  Flags deleted(bool deleted) => this(deleted: deleted);

  @override
  Flags flagged(bool flagged) => this(flagged: flagged);

  @override
  Flags noteLocked(bool noteLocked) => this(noteLocked: noteLocked);

  @override
  Flags pending(bool pending) => this(pending: pending);

  @override
  Flags ratingLocked(bool ratingLocked) => this(ratingLocked: ratingLocked);

  @override
  Flags statusLocked(bool statusLocked) => this(statusLocked: statusLocked);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Flags(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Flags(...).copyWith(id: 12, name: "My name")
  /// ````
  Flags call({
    Object? deleted = const $CopyWithPlaceholder(),
    Object? flagged = const $CopyWithPlaceholder(),
    Object? noteLocked = const $CopyWithPlaceholder(),
    Object? pending = const $CopyWithPlaceholder(),
    Object? ratingLocked = const $CopyWithPlaceholder(),
    Object? statusLocked = const $CopyWithPlaceholder(),
  }) {
    return Flags(
      deleted: deleted == const $CopyWithPlaceholder() || deleted == null
          ? _value.deleted
          // ignore: cast_nullable_to_non_nullable
          : deleted as bool,
      flagged: flagged == const $CopyWithPlaceholder() || flagged == null
          ? _value.flagged
          // ignore: cast_nullable_to_non_nullable
          : flagged as bool,
      noteLocked:
          noteLocked == const $CopyWithPlaceholder() || noteLocked == null
              ? _value.noteLocked
              // ignore: cast_nullable_to_non_nullable
              : noteLocked as bool,
      pending: pending == const $CopyWithPlaceholder() || pending == null
          ? _value.pending
          // ignore: cast_nullable_to_non_nullable
          : pending as bool,
      ratingLocked:
          ratingLocked == const $CopyWithPlaceholder() || ratingLocked == null
              ? _value.ratingLocked
              // ignore: cast_nullable_to_non_nullable
              : ratingLocked as bool,
      statusLocked:
          statusLocked == const $CopyWithPlaceholder() || statusLocked == null
              ? _value.statusLocked
              // ignore: cast_nullable_to_non_nullable
              : statusLocked as bool,
    );
  }
}

extension $FlagsCopyWith on Flags {
  /// Returns a callable class that can be used as follows: `instanceOfFlags.copyWith(...)` or like so:`instanceOfFlags.copyWith.fieldName(...)`.
  _$FlagsCWProxy get copyWith => _$FlagsCWProxyImpl(this);
}

abstract class _$RelationshipsCWProxy {
  Relationships children(List<int> children);

  Relationships hasActiveChildren(bool hasActiveChildren);

  Relationships hasChildren(bool hasChildren);

  Relationships parentId(int? parentId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relationships(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relationships(...).copyWith(id: 12, name: "My name")
  /// ````
  Relationships call({
    List<int>? children,
    bool? hasActiveChildren,
    bool? hasChildren,
    int? parentId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRelationships.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRelationships.copyWith.fieldName(...)`
class _$RelationshipsCWProxyImpl implements _$RelationshipsCWProxy {
  final Relationships _value;

  const _$RelationshipsCWProxyImpl(this._value);

  @override
  Relationships children(List<int> children) => this(children: children);

  @override
  Relationships hasActiveChildren(bool hasActiveChildren) =>
      this(hasActiveChildren: hasActiveChildren);

  @override
  Relationships hasChildren(bool hasChildren) => this(hasChildren: hasChildren);

  @override
  Relationships parentId(int? parentId) => this(parentId: parentId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Relationships(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Relationships(...).copyWith(id: 12, name: "My name")
  /// ````
  Relationships call({
    Object? children = const $CopyWithPlaceholder(),
    Object? hasActiveChildren = const $CopyWithPlaceholder(),
    Object? hasChildren = const $CopyWithPlaceholder(),
    Object? parentId = const $CopyWithPlaceholder(),
  }) {
    return Relationships(
      children: children == const $CopyWithPlaceholder() || children == null
          ? _value.children
          // ignore: cast_nullable_to_non_nullable
          : children as List<int>,
      hasActiveChildren: hasActiveChildren == const $CopyWithPlaceholder() ||
              hasActiveChildren == null
          ? _value.hasActiveChildren
          // ignore: cast_nullable_to_non_nullable
          : hasActiveChildren as bool,
      hasChildren:
          hasChildren == const $CopyWithPlaceholder() || hasChildren == null
              ? _value.hasChildren
              // ignore: cast_nullable_to_non_nullable
              : hasChildren as bool,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as int?,
    );
  }
}

extension $RelationshipsCopyWith on Relationships {
  /// Returns a callable class that can be used as follows: `instanceOfRelationships.copyWith(...)` or like so:`instanceOfRelationships.copyWith.fieldName(...)`.
  _$RelationshipsCWProxy get copyWith => _$RelationshipsCWProxyImpl(this);
}

abstract class _$ScoreCWProxy {
  Score down(int down);

  Score total(int total);

  Score up(int up);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Score(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Score(...).copyWith(id: 12, name: "My name")
  /// ````
  Score call({
    int? down,
    int? total,
    int? up,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScore.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScore.copyWith.fieldName(...)`
class _$ScoreCWProxyImpl implements _$ScoreCWProxy {
  final Score _value;

  const _$ScoreCWProxyImpl(this._value);

  @override
  Score down(int down) => this(down: down);

  @override
  Score total(int total) => this(total: total);

  @override
  Score up(int up) => this(up: up);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Score(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Score(...).copyWith(id: 12, name: "My name")
  /// ````
  Score call({
    Object? down = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? up = const $CopyWithPlaceholder(),
  }) {
    return Score(
      down: down == const $CopyWithPlaceholder() || down == null
          ? _value.down
          // ignore: cast_nullable_to_non_nullable
          : down as int,
      total: total == const $CopyWithPlaceholder() || total == null
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      up: up == const $CopyWithPlaceholder() || up == null
          ? _value.up
          // ignore: cast_nullable_to_non_nullable
          : up as int,
    );
  }
}

extension $ScoreCopyWith on Score {
  /// Returns a callable class that can be used as follows: `instanceOfScore.copyWith(...)` or like so:`instanceOfScore.copyWith.fieldName(...)`.
  _$ScoreCWProxy get copyWith => _$ScoreCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      file: PostSourceFile.fromJson(json['file'] as Map<String, dynamic>),
      preview:
          PostPreviewFile.fromJson(json['preview'] as Map<String, dynamic>),
      sample: PostSampleFile.fromJson(json['sample'] as Map<String, dynamic>),
      score: Score.fromJson(json['score'] as Map<String, dynamic>),
      tags: (json['tags'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lockedTags: (json['locked_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      changeSeq: json['change_seq'] as int?,
      flags: Flags.fromJson(json['flags'] as Map<String, dynamic>),
      rating: $enumDecode(_$RatingEnumMap, json['rating']),
      favCount: json['fav_count'] as int,
      sources:
          (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      pools: (json['pools'] as List<dynamic>).map((e) => e as int).toList(),
      relationships:
          Relationships.fromJson(json['relationships'] as Map<String, dynamic>),
      approverId: json['approver_id'] as int?,
      uploaderId: json['uploader_id'] as int,
      description: json['description'] as String,
      commentCount: json['comment_count'] as int,
      isFavorited: json['is_favorited'] as bool,
      hasNotes: json['has_notes'] as bool,
      duration: (json['duration'] as num?)?.toDouble(),
      voteStatus:
          $enumDecodeNullable(_$VoteStatusEnumMap, json['vote_status']) ??
              VoteStatus.unknown,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'vote_status': _$VoteStatusEnumMap[instance.voteStatus],
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'file': instance.file,
      'preview': instance.preview,
      'sample': instance.sample,
      'score': instance.score,
      'tags': instance.tags,
      'locked_tags': instance.lockedTags,
      'change_seq': instance.changeSeq,
      'flags': instance.flags,
      'rating': _$RatingEnumMap[instance.rating],
      'fav_count': instance.favCount,
      'sources': instance.sources,
      'pools': instance.pools,
      'relationships': instance.relationships,
      'approver_id': instance.approverId,
      'uploader_id': instance.uploaderId,
      'description': instance.description,
      'comment_count': instance.commentCount,
      'is_favorited': instance.isFavorited,
      'has_notes': instance.hasNotes,
      'duration': instance.duration,
    };

const _$RatingEnumMap = {
  Rating.s: 's',
  Rating.e: 'e',
  Rating.q: 'q',
};

const _$VoteStatusEnumMap = {
  VoteStatus.upvoted: 'upvoted',
  VoteStatus.unknown: 'unknown',
  VoteStatus.downvoted: 'downvoted',
};

PostPreviewFile _$PostPreviewFileFromJson(Map<String, dynamic> json) =>
    PostPreviewFile(
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PostPreviewFileToJson(PostPreviewFile instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };

PostSampleFile _$PostSampleFileFromJson(Map<String, dynamic> json) =>
    PostSampleFile(
      has: json['has'] as bool,
      height: json['height'] as int,
      width: json['width'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PostSampleFileToJson(PostSampleFile instance) =>
    <String, dynamic>{
      'has': instance.has,
      'height': instance.height,
      'width': instance.width,
      'url': instance.url,
    };

PostSourceFile _$PostSourceFileFromJson(Map<String, dynamic> json) =>
    PostSourceFile(
      width: json['width'] as int,
      height: json['height'] as int,
      ext: json['ext'] as String,
      size: json['size'] as int,
      md5: json['md5'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PostSourceFileToJson(PostSourceFile instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'ext': instance.ext,
      'size': instance.size,
      'md5': instance.md5,
      'url': instance.url,
    };

Flags _$FlagsFromJson(Map<String, dynamic> json) => Flags(
      pending: json['pending'] as bool,
      flagged: json['flagged'] as bool,
      noteLocked: json['note_locked'] as bool,
      statusLocked: json['status_locked'] as bool,
      ratingLocked: json['rating_locked'] as bool,
      deleted: json['deleted'] as bool,
    );

Map<String, dynamic> _$FlagsToJson(Flags instance) => <String, dynamic>{
      'pending': instance.pending,
      'flagged': instance.flagged,
      'note_locked': instance.noteLocked,
      'status_locked': instance.statusLocked,
      'rating_locked': instance.ratingLocked,
      'deleted': instance.deleted,
    };

Relationships _$RelationshipsFromJson(Map<String, dynamic> json) =>
    Relationships(
      parentId: json['parent_id'] as int?,
      hasChildren: json['has_children'] as bool,
      hasActiveChildren: json['has_active_children'] as bool,
      children:
          (json['children'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$RelationshipsToJson(Relationships instance) =>
    <String, dynamic>{
      'parent_id': instance.parentId,
      'has_children': instance.hasChildren,
      'has_active_children': instance.hasActiveChildren,
      'children': instance.children,
    };

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
      up: json['up'] as int,
      down: json['down'] as int,
      total: json['total'] as int,
    );

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
      'up': instance.up,
      'down': instance.down,
      'total': instance.total,
    };
