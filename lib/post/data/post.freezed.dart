// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'file')
  PostSourceFile get fileRaw => throw _privateConstructorUsedError;
  PostPreviewFile get preview => throw _privateConstructorUsedError;
  PostSampleFile get sample => throw _privateConstructorUsedError;
  Score get score => throw _privateConstructorUsedError;
  Map<String, List<String>> get tags => throw _privateConstructorUsedError;
  List<String>? get lockedTags => throw _privateConstructorUsedError;
  int? get changeSeq => throw _privateConstructorUsedError;
  Flags get flags => throw _privateConstructorUsedError;
  Rating get rating => throw _privateConstructorUsedError;
  int get favCount => throw _privateConstructorUsedError;
  List<String> get sources => throw _privateConstructorUsedError;
  List<int> get pools => throw _privateConstructorUsedError;
  Relationships get relationships => throw _privateConstructorUsedError;
  int? get approverId => throw _privateConstructorUsedError;
  int get uploaderId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get commentCount => throw _privateConstructorUsedError;
  bool get isFavorited => throw _privateConstructorUsedError;
  bool get hasNotes => throw _privateConstructorUsedError;
  double? get duration => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  VoteStatus get voteStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res>;
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'file') PostSourceFile fileRaw,
      PostPreviewFile preview,
      PostSampleFile sample,
      Score score,
      Map<String, List<String>> tags,
      List<String>? lockedTags,
      int? changeSeq,
      Flags flags,
      Rating rating,
      int favCount,
      List<String> sources,
      List<int> pools,
      Relationships relationships,
      int? approverId,
      int uploaderId,
      String description,
      int commentCount,
      bool isFavorited,
      bool hasNotes,
      double? duration,
      @JsonKey(ignore: true) VoteStatus voteStatus});

  $PostSourceFileCopyWith<$Res> get fileRaw;
  $PostPreviewFileCopyWith<$Res> get preview;
  $PostSampleFileCopyWith<$Res> get sample;
  $ScoreCopyWith<$Res> get score;
  $FlagsCopyWith<$Res> get flags;
  $RelationshipsCopyWith<$Res> get relationships;
}

/// @nodoc
class _$PostCopyWithImpl<$Res> implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  final Post _value;
  // ignore: unused_field
  final $Res Function(Post) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? fileRaw = freezed,
    Object? preview = freezed,
    Object? sample = freezed,
    Object? score = freezed,
    Object? tags = freezed,
    Object? lockedTags = freezed,
    Object? changeSeq = freezed,
    Object? flags = freezed,
    Object? rating = freezed,
    Object? favCount = freezed,
    Object? sources = freezed,
    Object? pools = freezed,
    Object? relationships = freezed,
    Object? approverId = freezed,
    Object? uploaderId = freezed,
    Object? description = freezed,
    Object? commentCount = freezed,
    Object? isFavorited = freezed,
    Object? hasNotes = freezed,
    Object? duration = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileRaw: fileRaw == freezed
          ? _value.fileRaw
          : fileRaw // ignore: cast_nullable_to_non_nullable
              as PostSourceFile,
      preview: preview == freezed
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as PostPreviewFile,
      sample: sample == freezed
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as PostSampleFile,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as Score,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lockedTags: lockedTags == freezed
          ? _value.lockedTags
          : lockedTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      changeSeq: changeSeq == freezed
          ? _value.changeSeq
          : changeSeq // ignore: cast_nullable_to_non_nullable
              as int?,
      flags: flags == freezed
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Flags,
      rating: rating == freezed
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: favCount == freezed
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      sources: sources == freezed
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: pools == freezed
          ? _value.pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>,
      relationships: relationships == freezed
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
      approverId: approverId == freezed
          ? _value.approverId
          : approverId // ignore: cast_nullable_to_non_nullable
              as int?,
      uploaderId: uploaderId == freezed
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      commentCount: commentCount == freezed
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: isFavorited == freezed
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNotes: hasNotes == freezed
          ? _value.hasNotes
          : hasNotes // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      voteStatus: voteStatus == freezed
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }

  @override
  $PostSourceFileCopyWith<$Res> get fileRaw {
    return $PostSourceFileCopyWith<$Res>(_value.fileRaw, (value) {
      return _then(_value.copyWith(fileRaw: value));
    });
  }

  @override
  $PostPreviewFileCopyWith<$Res> get preview {
    return $PostPreviewFileCopyWith<$Res>(_value.preview, (value) {
      return _then(_value.copyWith(preview: value));
    });
  }

  @override
  $PostSampleFileCopyWith<$Res> get sample {
    return $PostSampleFileCopyWith<$Res>(_value.sample, (value) {
      return _then(_value.copyWith(sample: value));
    });
  }

  @override
  $ScoreCopyWith<$Res> get score {
    return $ScoreCopyWith<$Res>(_value.score, (value) {
      return _then(_value.copyWith(score: value));
    });
  }

  @override
  $FlagsCopyWith<$Res> get flags {
    return $FlagsCopyWith<$Res>(_value.flags, (value) {
      return _then(_value.copyWith(flags: value));
    });
  }

  @override
  $RelationshipsCopyWith<$Res> get relationships {
    return $RelationshipsCopyWith<$Res>(_value.relationships, (value) {
      return _then(_value.copyWith(relationships: value));
    });
  }
}

/// @nodoc
abstract class _$$_PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$_PostCopyWith(_$_Post value, $Res Function(_$_Post) then) =
      __$$_PostCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime? updatedAt,
      @JsonKey(name: 'file') PostSourceFile fileRaw,
      PostPreviewFile preview,
      PostSampleFile sample,
      Score score,
      Map<String, List<String>> tags,
      List<String>? lockedTags,
      int? changeSeq,
      Flags flags,
      Rating rating,
      int favCount,
      List<String> sources,
      List<int> pools,
      Relationships relationships,
      int? approverId,
      int uploaderId,
      String description,
      int commentCount,
      bool isFavorited,
      bool hasNotes,
      double? duration,
      @JsonKey(ignore: true) VoteStatus voteStatus});

  @override
  $PostSourceFileCopyWith<$Res> get fileRaw;
  @override
  $PostPreviewFileCopyWith<$Res> get preview;
  @override
  $PostSampleFileCopyWith<$Res> get sample;
  @override
  $ScoreCopyWith<$Res> get score;
  @override
  $FlagsCopyWith<$Res> get flags;
  @override
  $RelationshipsCopyWith<$Res> get relationships;
}

/// @nodoc
class __$$_PostCopyWithImpl<$Res> extends _$PostCopyWithImpl<$Res>
    implements _$$_PostCopyWith<$Res> {
  __$$_PostCopyWithImpl(_$_Post _value, $Res Function(_$_Post) _then)
      : super(_value, (v) => _then(v as _$_Post));

  @override
  _$_Post get _value => super._value as _$_Post;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? fileRaw = freezed,
    Object? preview = freezed,
    Object? sample = freezed,
    Object? score = freezed,
    Object? tags = freezed,
    Object? lockedTags = freezed,
    Object? changeSeq = freezed,
    Object? flags = freezed,
    Object? rating = freezed,
    Object? favCount = freezed,
    Object? sources = freezed,
    Object? pools = freezed,
    Object? relationships = freezed,
    Object? approverId = freezed,
    Object? uploaderId = freezed,
    Object? description = freezed,
    Object? commentCount = freezed,
    Object? isFavorited = freezed,
    Object? hasNotes = freezed,
    Object? duration = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_$_Post(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileRaw: fileRaw == freezed
          ? _value.fileRaw
          : fileRaw // ignore: cast_nullable_to_non_nullable
              as PostSourceFile,
      preview: preview == freezed
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as PostPreviewFile,
      sample: sample == freezed
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as PostSampleFile,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as Score,
      tags: tags == freezed
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lockedTags: lockedTags == freezed
          ? _value._lockedTags
          : lockedTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      changeSeq: changeSeq == freezed
          ? _value.changeSeq
          : changeSeq // ignore: cast_nullable_to_non_nullable
              as int?,
      flags: flags == freezed
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Flags,
      rating: rating == freezed
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: favCount == freezed
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      sources: sources == freezed
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: pools == freezed
          ? _value._pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>,
      relationships: relationships == freezed
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
      approverId: approverId == freezed
          ? _value.approverId
          : approverId // ignore: cast_nullable_to_non_nullable
              as int?,
      uploaderId: uploaderId == freezed
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      commentCount: commentCount == freezed
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: isFavorited == freezed
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNotes: hasNotes == freezed
          ? _value.hasNotes
          : hasNotes // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      voteStatus: voteStatus == freezed
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Post extends _Post {
  const _$_Post(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: 'file') required this.fileRaw,
      required this.preview,
      required this.sample,
      required this.score,
      required final Map<String, List<String>> tags,
      required final List<String>? lockedTags,
      required this.changeSeq,
      required this.flags,
      required this.rating,
      required this.favCount,
      required final List<String> sources,
      required final List<int> pools,
      required this.relationships,
      required this.approverId,
      required this.uploaderId,
      required this.description,
      required this.commentCount,
      required this.isFavorited,
      required this.hasNotes,
      required this.duration,
      @JsonKey(ignore: true) this.voteStatus = VoteStatus.unknown})
      : _tags = tags,
        _lockedTags = lockedTags,
        _sources = sources,
        _pools = pools,
        super._();

  factory _$_Post.fromJson(Map<String, dynamic> json) => _$$_PostFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'file')
  final PostSourceFile fileRaw;
  @override
  final PostPreviewFile preview;
  @override
  final PostSampleFile sample;
  @override
  final Score score;
  final Map<String, List<String>> _tags;
  @override
  Map<String, List<String>> get tags {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tags);
  }

  final List<String>? _lockedTags;
  @override
  List<String>? get lockedTags {
    final value = _lockedTags;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? changeSeq;
  @override
  final Flags flags;
  @override
  final Rating rating;
  @override
  final int favCount;
  final List<String> _sources;
  @override
  List<String> get sources {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  final List<int> _pools;
  @override
  List<int> get pools {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pools);
  }

  @override
  final Relationships relationships;
  @override
  final int? approverId;
  @override
  final int uploaderId;
  @override
  final String description;
  @override
  final int commentCount;
  @override
  final bool isFavorited;
  @override
  final bool hasNotes;
  @override
  final double? duration;
  @override
  @JsonKey(ignore: true)
  final VoteStatus voteStatus;

  @override
  String toString() {
    return 'Post(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, fileRaw: $fileRaw, preview: $preview, sample: $sample, score: $score, tags: $tags, lockedTags: $lockedTags, changeSeq: $changeSeq, flags: $flags, rating: $rating, favCount: $favCount, sources: $sources, pools: $pools, relationships: $relationships, approverId: $approverId, uploaderId: $uploaderId, description: $description, commentCount: $commentCount, isFavorited: $isFavorited, hasNotes: $hasNotes, duration: $duration, voteStatus: $voteStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Post &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality().equals(other.fileRaw, fileRaw) &&
            const DeepCollectionEquality().equals(other.preview, preview) &&
            const DeepCollectionEquality().equals(other.sample, sample) &&
            const DeepCollectionEquality().equals(other.score, score) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._lockedTags, _lockedTags) &&
            const DeepCollectionEquality().equals(other.changeSeq, changeSeq) &&
            const DeepCollectionEquality().equals(other.flags, flags) &&
            const DeepCollectionEquality().equals(other.rating, rating) &&
            const DeepCollectionEquality().equals(other.favCount, favCount) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            const DeepCollectionEquality().equals(other._pools, _pools) &&
            const DeepCollectionEquality()
                .equals(other.relationships, relationships) &&
            const DeepCollectionEquality()
                .equals(other.approverId, approverId) &&
            const DeepCollectionEquality()
                .equals(other.uploaderId, uploaderId) &&
            const DeepCollectionEquality()
                .equals(other.description, description) &&
            const DeepCollectionEquality()
                .equals(other.commentCount, commentCount) &&
            const DeepCollectionEquality()
                .equals(other.isFavorited, isFavorited) &&
            const DeepCollectionEquality().equals(other.hasNotes, hasNotes) &&
            const DeepCollectionEquality().equals(other.duration, duration) &&
            const DeepCollectionEquality()
                .equals(other.voteStatus, voteStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(createdAt),
        const DeepCollectionEquality().hash(updatedAt),
        const DeepCollectionEquality().hash(fileRaw),
        const DeepCollectionEquality().hash(preview),
        const DeepCollectionEquality().hash(sample),
        const DeepCollectionEquality().hash(score),
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_lockedTags),
        const DeepCollectionEquality().hash(changeSeq),
        const DeepCollectionEquality().hash(flags),
        const DeepCollectionEquality().hash(rating),
        const DeepCollectionEquality().hash(favCount),
        const DeepCollectionEquality().hash(_sources),
        const DeepCollectionEquality().hash(_pools),
        const DeepCollectionEquality().hash(relationships),
        const DeepCollectionEquality().hash(approverId),
        const DeepCollectionEquality().hash(uploaderId),
        const DeepCollectionEquality().hash(description),
        const DeepCollectionEquality().hash(commentCount),
        const DeepCollectionEquality().hash(isFavorited),
        const DeepCollectionEquality().hash(hasNotes),
        const DeepCollectionEquality().hash(duration),
        const DeepCollectionEquality().hash(voteStatus)
      ]);

  @JsonKey(ignore: true)
  @override
  _$$_PostCopyWith<_$_Post> get copyWith =>
      __$$_PostCopyWithImpl<_$_Post>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PostToJson(
      this,
    );
  }
}

abstract class _Post extends Post {
  const factory _Post(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime? updatedAt,
      @JsonKey(name: 'file') required final PostSourceFile fileRaw,
      required final PostPreviewFile preview,
      required final PostSampleFile sample,
      required final Score score,
      required final Map<String, List<String>> tags,
      required final List<String>? lockedTags,
      required final int? changeSeq,
      required final Flags flags,
      required final Rating rating,
      required final int favCount,
      required final List<String> sources,
      required final List<int> pools,
      required final Relationships relationships,
      required final int? approverId,
      required final int uploaderId,
      required final String description,
      required final int commentCount,
      required final bool isFavorited,
      required final bool hasNotes,
      required final double? duration,
      @JsonKey(ignore: true) final VoteStatus voteStatus}) = _$_Post;
  const _Post._() : super._();

  factory _Post.fromJson(Map<String, dynamic> json) = _$_Post.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'file')
  PostSourceFile get fileRaw;
  @override
  PostPreviewFile get preview;
  @override
  PostSampleFile get sample;
  @override
  Score get score;
  @override
  Map<String, List<String>> get tags;
  @override
  List<String>? get lockedTags;
  @override
  int? get changeSeq;
  @override
  Flags get flags;
  @override
  Rating get rating;
  @override
  int get favCount;
  @override
  List<String> get sources;
  @override
  List<int> get pools;
  @override
  Relationships get relationships;
  @override
  int? get approverId;
  @override
  int get uploaderId;
  @override
  String get description;
  @override
  int get commentCount;
  @override
  bool get isFavorited;
  @override
  bool get hasNotes;
  @override
  double? get duration;
  @override
  @JsonKey(ignore: true)
  VoteStatus get voteStatus;
  @override
  @JsonKey(ignore: true)
  _$$_PostCopyWith<_$_Post> get copyWith => throw _privateConstructorUsedError;
}

PostPreviewFile _$PostPreviewFileFromJson(Map<String, dynamic> json) {
  return _PostPreviewFile.fromJson(json);
}

/// @nodoc
mixin _$PostPreviewFile {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostPreviewFileCopyWith<PostPreviewFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostPreviewFileCopyWith<$Res> {
  factory $PostPreviewFileCopyWith(
          PostPreviewFile value, $Res Function(PostPreviewFile) then) =
      _$PostPreviewFileCopyWithImpl<$Res>;
  $Res call({int width, int height, String? url});
}

/// @nodoc
class _$PostPreviewFileCopyWithImpl<$Res>
    implements $PostPreviewFileCopyWith<$Res> {
  _$PostPreviewFileCopyWithImpl(this._value, this._then);

  final PostPreviewFile _value;
  // ignore: unused_field
  final $Res Function(PostPreviewFile) _then;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_PostPreviewFileCopyWith<$Res>
    implements $PostPreviewFileCopyWith<$Res> {
  factory _$$_PostPreviewFileCopyWith(
          _$_PostPreviewFile value, $Res Function(_$_PostPreviewFile) then) =
      __$$_PostPreviewFileCopyWithImpl<$Res>;
  @override
  $Res call({int width, int height, String? url});
}

/// @nodoc
class __$$_PostPreviewFileCopyWithImpl<$Res>
    extends _$PostPreviewFileCopyWithImpl<$Res>
    implements _$$_PostPreviewFileCopyWith<$Res> {
  __$$_PostPreviewFileCopyWithImpl(
      _$_PostPreviewFile _value, $Res Function(_$_PostPreviewFile) _then)
      : super(_value, (v) => _then(v as _$_PostPreviewFile));

  @override
  _$_PostPreviewFile get _value => super._value as _$_PostPreviewFile;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? url = freezed,
  }) {
    return _then(_$_PostPreviewFile(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PostPreviewFile implements _PostPreviewFile {
  const _$_PostPreviewFile(
      {required this.width, required this.height, required this.url});

  factory _$_PostPreviewFile.fromJson(Map<String, dynamic> json) =>
      _$$_PostPreviewFileFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final String? url;

  @override
  String toString() {
    return 'PostPreviewFile(width: $width, height: $height, url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PostPreviewFile &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.url, url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(url));

  @JsonKey(ignore: true)
  @override
  _$$_PostPreviewFileCopyWith<_$_PostPreviewFile> get copyWith =>
      __$$_PostPreviewFileCopyWithImpl<_$_PostPreviewFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PostPreviewFileToJson(
      this,
    );
  }
}

abstract class _PostPreviewFile implements PostPreviewFile {
  const factory _PostPreviewFile(
      {required final int width,
      required final int height,
      required final String? url}) = _$_PostPreviewFile;

  factory _PostPreviewFile.fromJson(Map<String, dynamic> json) =
      _$_PostPreviewFile.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$_PostPreviewFileCopyWith<_$_PostPreviewFile> get copyWith =>
      throw _privateConstructorUsedError;
}

PostSampleFile _$PostSampleFileFromJson(Map<String, dynamic> json) {
  return _PostSampleFile.fromJson(json);
}

/// @nodoc
mixin _$PostSampleFile {
  bool get has => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostSampleFileCopyWith<PostSampleFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostSampleFileCopyWith<$Res> {
  factory $PostSampleFileCopyWith(
          PostSampleFile value, $Res Function(PostSampleFile) then) =
      _$PostSampleFileCopyWithImpl<$Res>;
  $Res call({bool has, int height, int width, String? url});
}

/// @nodoc
class _$PostSampleFileCopyWithImpl<$Res>
    implements $PostSampleFileCopyWith<$Res> {
  _$PostSampleFileCopyWithImpl(this._value, this._then);

  final PostSampleFile _value;
  // ignore: unused_field
  final $Res Function(PostSampleFile) _then;

  @override
  $Res call({
    Object? has = freezed,
    Object? height = freezed,
    Object? width = freezed,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      has: has == freezed
          ? _value.has
          : has // ignore: cast_nullable_to_non_nullable
              as bool,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_PostSampleFileCopyWith<$Res>
    implements $PostSampleFileCopyWith<$Res> {
  factory _$$_PostSampleFileCopyWith(
          _$_PostSampleFile value, $Res Function(_$_PostSampleFile) then) =
      __$$_PostSampleFileCopyWithImpl<$Res>;
  @override
  $Res call({bool has, int height, int width, String? url});
}

/// @nodoc
class __$$_PostSampleFileCopyWithImpl<$Res>
    extends _$PostSampleFileCopyWithImpl<$Res>
    implements _$$_PostSampleFileCopyWith<$Res> {
  __$$_PostSampleFileCopyWithImpl(
      _$_PostSampleFile _value, $Res Function(_$_PostSampleFile) _then)
      : super(_value, (v) => _then(v as _$_PostSampleFile));

  @override
  _$_PostSampleFile get _value => super._value as _$_PostSampleFile;

  @override
  $Res call({
    Object? has = freezed,
    Object? height = freezed,
    Object? width = freezed,
    Object? url = freezed,
  }) {
    return _then(_$_PostSampleFile(
      has: has == freezed
          ? _value.has
          : has // ignore: cast_nullable_to_non_nullable
              as bool,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PostSampleFile implements _PostSampleFile {
  const _$_PostSampleFile(
      {required this.has,
      required this.height,
      required this.width,
      required this.url});

  factory _$_PostSampleFile.fromJson(Map<String, dynamic> json) =>
      _$$_PostSampleFileFromJson(json);

  @override
  final bool has;
  @override
  final int height;
  @override
  final int width;
  @override
  final String? url;

  @override
  String toString() {
    return 'PostSampleFile(has: $has, height: $height, width: $width, url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PostSampleFile &&
            const DeepCollectionEquality().equals(other.has, has) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.url, url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(has),
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(url));

  @JsonKey(ignore: true)
  @override
  _$$_PostSampleFileCopyWith<_$_PostSampleFile> get copyWith =>
      __$$_PostSampleFileCopyWithImpl<_$_PostSampleFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PostSampleFileToJson(
      this,
    );
  }
}

abstract class _PostSampleFile implements PostSampleFile {
  const factory _PostSampleFile(
      {required final bool has,
      required final int height,
      required final int width,
      required final String? url}) = _$_PostSampleFile;

  factory _PostSampleFile.fromJson(Map<String, dynamic> json) =
      _$_PostSampleFile.fromJson;

  @override
  bool get has;
  @override
  int get height;
  @override
  int get width;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$_PostSampleFileCopyWith<_$_PostSampleFile> get copyWith =>
      throw _privateConstructorUsedError;
}

PostSourceFile _$PostSourceFileFromJson(Map<String, dynamic> json) {
  return _PostSourceFile.fromJson(json);
}

/// @nodoc
mixin _$PostSourceFile {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String get ext => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String get md5 => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostSourceFileCopyWith<PostSourceFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostSourceFileCopyWith<$Res> {
  factory $PostSourceFileCopyWith(
          PostSourceFile value, $Res Function(PostSourceFile) then) =
      _$PostSourceFileCopyWithImpl<$Res>;
  $Res call(
      {int width, int height, String ext, int size, String md5, String? url});
}

/// @nodoc
class _$PostSourceFileCopyWithImpl<$Res>
    implements $PostSourceFileCopyWith<$Res> {
  _$PostSourceFileCopyWithImpl(this._value, this._then);

  final PostSourceFile _value;
  // ignore: unused_field
  final $Res Function(PostSourceFile) _then;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? ext = freezed,
    Object? size = freezed,
    Object? md5 = freezed,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      ext: ext == freezed
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      md5: md5 == freezed
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_PostSourceFileCopyWith<$Res>
    implements $PostSourceFileCopyWith<$Res> {
  factory _$$_PostSourceFileCopyWith(
          _$_PostSourceFile value, $Res Function(_$_PostSourceFile) then) =
      __$$_PostSourceFileCopyWithImpl<$Res>;
  @override
  $Res call(
      {int width, int height, String ext, int size, String md5, String? url});
}

/// @nodoc
class __$$_PostSourceFileCopyWithImpl<$Res>
    extends _$PostSourceFileCopyWithImpl<$Res>
    implements _$$_PostSourceFileCopyWith<$Res> {
  __$$_PostSourceFileCopyWithImpl(
      _$_PostSourceFile _value, $Res Function(_$_PostSourceFile) _then)
      : super(_value, (v) => _then(v as _$_PostSourceFile));

  @override
  _$_PostSourceFile get _value => super._value as _$_PostSourceFile;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? ext = freezed,
    Object? size = freezed,
    Object? md5 = freezed,
    Object? url = freezed,
  }) {
    return _then(_$_PostSourceFile(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      ext: ext == freezed
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      size: size == freezed
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      md5: md5 == freezed
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PostSourceFile implements _PostSourceFile {
  const _$_PostSourceFile(
      {required this.width,
      required this.height,
      required this.ext,
      required this.size,
      required this.md5,
      required this.url});

  factory _$_PostSourceFile.fromJson(Map<String, dynamic> json) =>
      _$$_PostSourceFileFromJson(json);

  @override
  final int width;
  @override
  final int height;
  @override
  final String ext;
  @override
  final int size;
  @override
  final String md5;
  @override
  final String? url;

  @override
  String toString() {
    return 'PostSourceFile(width: $width, height: $height, ext: $ext, size: $size, md5: $md5, url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PostSourceFile &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.ext, ext) &&
            const DeepCollectionEquality().equals(other.size, size) &&
            const DeepCollectionEquality().equals(other.md5, md5) &&
            const DeepCollectionEquality().equals(other.url, url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(ext),
      const DeepCollectionEquality().hash(size),
      const DeepCollectionEquality().hash(md5),
      const DeepCollectionEquality().hash(url));

  @JsonKey(ignore: true)
  @override
  _$$_PostSourceFileCopyWith<_$_PostSourceFile> get copyWith =>
      __$$_PostSourceFileCopyWithImpl<_$_PostSourceFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PostSourceFileToJson(
      this,
    );
  }
}

abstract class _PostSourceFile implements PostSourceFile {
  const factory _PostSourceFile(
      {required final int width,
      required final int height,
      required final String ext,
      required final int size,
      required final String md5,
      required final String? url}) = _$_PostSourceFile;

  factory _PostSourceFile.fromJson(Map<String, dynamic> json) =
      _$_PostSourceFile.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String get ext;
  @override
  int get size;
  @override
  String get md5;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$_PostSourceFileCopyWith<_$_PostSourceFile> get copyWith =>
      throw _privateConstructorUsedError;
}

Flags _$FlagsFromJson(Map<String, dynamic> json) {
  return _Flags.fromJson(json);
}

/// @nodoc
mixin _$Flags {
  bool get pending => throw _privateConstructorUsedError;
  bool get flagged => throw _privateConstructorUsedError;
  bool get noteLocked => throw _privateConstructorUsedError;
  bool get statusLocked => throw _privateConstructorUsedError;
  bool get ratingLocked => throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlagsCopyWith<Flags> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlagsCopyWith<$Res> {
  factory $FlagsCopyWith(Flags value, $Res Function(Flags) then) =
      _$FlagsCopyWithImpl<$Res>;
  $Res call(
      {bool pending,
      bool flagged,
      bool noteLocked,
      bool statusLocked,
      bool ratingLocked,
      bool deleted});
}

/// @nodoc
class _$FlagsCopyWithImpl<$Res> implements $FlagsCopyWith<$Res> {
  _$FlagsCopyWithImpl(this._value, this._then);

  final Flags _value;
  // ignore: unused_field
  final $Res Function(Flags) _then;

  @override
  $Res call({
    Object? pending = freezed,
    Object? flagged = freezed,
    Object? noteLocked = freezed,
    Object? statusLocked = freezed,
    Object? ratingLocked = freezed,
    Object? deleted = freezed,
  }) {
    return _then(_value.copyWith(
      pending: pending == freezed
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as bool,
      flagged: flagged == freezed
          ? _value.flagged
          : flagged // ignore: cast_nullable_to_non_nullable
              as bool,
      noteLocked: noteLocked == freezed
          ? _value.noteLocked
          : noteLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      statusLocked: statusLocked == freezed
          ? _value.statusLocked
          : statusLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingLocked: ratingLocked == freezed
          ? _value.ratingLocked
          : ratingLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: deleted == freezed
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_FlagsCopyWith<$Res> implements $FlagsCopyWith<$Res> {
  factory _$$_FlagsCopyWith(_$_Flags value, $Res Function(_$_Flags) then) =
      __$$_FlagsCopyWithImpl<$Res>;
  @override
  $Res call(
      {bool pending,
      bool flagged,
      bool noteLocked,
      bool statusLocked,
      bool ratingLocked,
      bool deleted});
}

/// @nodoc
class __$$_FlagsCopyWithImpl<$Res> extends _$FlagsCopyWithImpl<$Res>
    implements _$$_FlagsCopyWith<$Res> {
  __$$_FlagsCopyWithImpl(_$_Flags _value, $Res Function(_$_Flags) _then)
      : super(_value, (v) => _then(v as _$_Flags));

  @override
  _$_Flags get _value => super._value as _$_Flags;

  @override
  $Res call({
    Object? pending = freezed,
    Object? flagged = freezed,
    Object? noteLocked = freezed,
    Object? statusLocked = freezed,
    Object? ratingLocked = freezed,
    Object? deleted = freezed,
  }) {
    return _then(_$_Flags(
      pending: pending == freezed
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as bool,
      flagged: flagged == freezed
          ? _value.flagged
          : flagged // ignore: cast_nullable_to_non_nullable
              as bool,
      noteLocked: noteLocked == freezed
          ? _value.noteLocked
          : noteLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      statusLocked: statusLocked == freezed
          ? _value.statusLocked
          : statusLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingLocked: ratingLocked == freezed
          ? _value.ratingLocked
          : ratingLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: deleted == freezed
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Flags implements _Flags {
  const _$_Flags(
      {required this.pending,
      required this.flagged,
      required this.noteLocked,
      required this.statusLocked,
      required this.ratingLocked,
      required this.deleted});

  factory _$_Flags.fromJson(Map<String, dynamic> json) =>
      _$$_FlagsFromJson(json);

  @override
  final bool pending;
  @override
  final bool flagged;
  @override
  final bool noteLocked;
  @override
  final bool statusLocked;
  @override
  final bool ratingLocked;
  @override
  final bool deleted;

  @override
  String toString() {
    return 'Flags(pending: $pending, flagged: $flagged, noteLocked: $noteLocked, statusLocked: $statusLocked, ratingLocked: $ratingLocked, deleted: $deleted)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Flags &&
            const DeepCollectionEquality().equals(other.pending, pending) &&
            const DeepCollectionEquality().equals(other.flagged, flagged) &&
            const DeepCollectionEquality()
                .equals(other.noteLocked, noteLocked) &&
            const DeepCollectionEquality()
                .equals(other.statusLocked, statusLocked) &&
            const DeepCollectionEquality()
                .equals(other.ratingLocked, ratingLocked) &&
            const DeepCollectionEquality().equals(other.deleted, deleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(pending),
      const DeepCollectionEquality().hash(flagged),
      const DeepCollectionEquality().hash(noteLocked),
      const DeepCollectionEquality().hash(statusLocked),
      const DeepCollectionEquality().hash(ratingLocked),
      const DeepCollectionEquality().hash(deleted));

  @JsonKey(ignore: true)
  @override
  _$$_FlagsCopyWith<_$_Flags> get copyWith =>
      __$$_FlagsCopyWithImpl<_$_Flags>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FlagsToJson(
      this,
    );
  }
}

abstract class _Flags implements Flags {
  const factory _Flags(
      {required final bool pending,
      required final bool flagged,
      required final bool noteLocked,
      required final bool statusLocked,
      required final bool ratingLocked,
      required final bool deleted}) = _$_Flags;

  factory _Flags.fromJson(Map<String, dynamic> json) = _$_Flags.fromJson;

  @override
  bool get pending;
  @override
  bool get flagged;
  @override
  bool get noteLocked;
  @override
  bool get statusLocked;
  @override
  bool get ratingLocked;
  @override
  bool get deleted;
  @override
  @JsonKey(ignore: true)
  _$$_FlagsCopyWith<_$_Flags> get copyWith =>
      throw _privateConstructorUsedError;
}

Relationships _$RelationshipsFromJson(Map<String, dynamic> json) {
  return _Relationships.fromJson(json);
}

/// @nodoc
mixin _$Relationships {
  int? get parentId => throw _privateConstructorUsedError;
  bool get hasChildren => throw _privateConstructorUsedError;
  bool get hasActiveChildren => throw _privateConstructorUsedError;
  List<int> get children => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RelationshipsCopyWith<Relationships> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelationshipsCopyWith<$Res> {
  factory $RelationshipsCopyWith(
          Relationships value, $Res Function(Relationships) then) =
      _$RelationshipsCopyWithImpl<$Res>;
  $Res call(
      {int? parentId,
      bool hasChildren,
      bool hasActiveChildren,
      List<int> children});
}

/// @nodoc
class _$RelationshipsCopyWithImpl<$Res>
    implements $RelationshipsCopyWith<$Res> {
  _$RelationshipsCopyWithImpl(this._value, this._then);

  final Relationships _value;
  // ignore: unused_field
  final $Res Function(Relationships) _then;

  @override
  $Res call({
    Object? parentId = freezed,
    Object? hasChildren = freezed,
    Object? hasActiveChildren = freezed,
    Object? children = freezed,
  }) {
    return _then(_value.copyWith(
      parentId: parentId == freezed
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasChildren: hasChildren == freezed
          ? _value.hasChildren
          : hasChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChildren: hasActiveChildren == freezed
          ? _value.hasActiveChildren
          : hasActiveChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      children: children == freezed
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
abstract class _$$_RelationshipsCopyWith<$Res>
    implements $RelationshipsCopyWith<$Res> {
  factory _$$_RelationshipsCopyWith(
          _$_Relationships value, $Res Function(_$_Relationships) then) =
      __$$_RelationshipsCopyWithImpl<$Res>;
  @override
  $Res call(
      {int? parentId,
      bool hasChildren,
      bool hasActiveChildren,
      List<int> children});
}

/// @nodoc
class __$$_RelationshipsCopyWithImpl<$Res>
    extends _$RelationshipsCopyWithImpl<$Res>
    implements _$$_RelationshipsCopyWith<$Res> {
  __$$_RelationshipsCopyWithImpl(
      _$_Relationships _value, $Res Function(_$_Relationships) _then)
      : super(_value, (v) => _then(v as _$_Relationships));

  @override
  _$_Relationships get _value => super._value as _$_Relationships;

  @override
  $Res call({
    Object? parentId = freezed,
    Object? hasChildren = freezed,
    Object? hasActiveChildren = freezed,
    Object? children = freezed,
  }) {
    return _then(_$_Relationships(
      parentId: parentId == freezed
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasChildren: hasChildren == freezed
          ? _value.hasChildren
          : hasChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChildren: hasActiveChildren == freezed
          ? _value.hasActiveChildren
          : hasActiveChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      children: children == freezed
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Relationships implements _Relationships {
  const _$_Relationships(
      {required this.parentId,
      required this.hasChildren,
      required this.hasActiveChildren,
      required final List<int> children})
      : _children = children;

  factory _$_Relationships.fromJson(Map<String, dynamic> json) =>
      _$$_RelationshipsFromJson(json);

  @override
  final int? parentId;
  @override
  final bool hasChildren;
  @override
  final bool hasActiveChildren;
  final List<int> _children;
  @override
  List<int> get children {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'Relationships(parentId: $parentId, hasChildren: $hasChildren, hasActiveChildren: $hasActiveChildren, children: $children)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Relationships &&
            const DeepCollectionEquality().equals(other.parentId, parentId) &&
            const DeepCollectionEquality()
                .equals(other.hasChildren, hasChildren) &&
            const DeepCollectionEquality()
                .equals(other.hasActiveChildren, hasActiveChildren) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(parentId),
      const DeepCollectionEquality().hash(hasChildren),
      const DeepCollectionEquality().hash(hasActiveChildren),
      const DeepCollectionEquality().hash(_children));

  @JsonKey(ignore: true)
  @override
  _$$_RelationshipsCopyWith<_$_Relationships> get copyWith =>
      __$$_RelationshipsCopyWithImpl<_$_Relationships>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RelationshipsToJson(
      this,
    );
  }
}

abstract class _Relationships implements Relationships {
  const factory _Relationships(
      {required final int? parentId,
      required final bool hasChildren,
      required final bool hasActiveChildren,
      required final List<int> children}) = _$_Relationships;

  factory _Relationships.fromJson(Map<String, dynamic> json) =
      _$_Relationships.fromJson;

  @override
  int? get parentId;
  @override
  bool get hasChildren;
  @override
  bool get hasActiveChildren;
  @override
  List<int> get children;
  @override
  @JsonKey(ignore: true)
  _$$_RelationshipsCopyWith<_$_Relationships> get copyWith =>
      throw _privateConstructorUsedError;
}

Score _$ScoreFromJson(Map<String, dynamic> json) {
  return _Score.fromJson(json);
}

/// @nodoc
mixin _$Score {
  int get up => throw _privateConstructorUsedError;
  int get down => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScoreCopyWith<Score> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreCopyWith<$Res> {
  factory $ScoreCopyWith(Score value, $Res Function(Score) then) =
      _$ScoreCopyWithImpl<$Res>;
  $Res call({int up, int down, int total});
}

/// @nodoc
class _$ScoreCopyWithImpl<$Res> implements $ScoreCopyWith<$Res> {
  _$ScoreCopyWithImpl(this._value, this._then);

  final Score _value;
  // ignore: unused_field
  final $Res Function(Score) _then;

  @override
  $Res call({
    Object? up = freezed,
    Object? down = freezed,
    Object? total = freezed,
  }) {
    return _then(_value.copyWith(
      up: up == freezed
          ? _value.up
          : up // ignore: cast_nullable_to_non_nullable
              as int,
      down: down == freezed
          ? _value.down
          : down // ignore: cast_nullable_to_non_nullable
              as int,
      total: total == freezed
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$_ScoreCopyWith<$Res> implements $ScoreCopyWith<$Res> {
  factory _$$_ScoreCopyWith(_$_Score value, $Res Function(_$_Score) then) =
      __$$_ScoreCopyWithImpl<$Res>;
  @override
  $Res call({int up, int down, int total});
}

/// @nodoc
class __$$_ScoreCopyWithImpl<$Res> extends _$ScoreCopyWithImpl<$Res>
    implements _$$_ScoreCopyWith<$Res> {
  __$$_ScoreCopyWithImpl(_$_Score _value, $Res Function(_$_Score) _then)
      : super(_value, (v) => _then(v as _$_Score));

  @override
  _$_Score get _value => super._value as _$_Score;

  @override
  $Res call({
    Object? up = freezed,
    Object? down = freezed,
    Object? total = freezed,
  }) {
    return _then(_$_Score(
      up: up == freezed
          ? _value.up
          : up // ignore: cast_nullable_to_non_nullable
              as int,
      down: down == freezed
          ? _value.down
          : down // ignore: cast_nullable_to_non_nullable
              as int,
      total: total == freezed
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Score implements _Score {
  const _$_Score({required this.up, required this.down, required this.total});

  factory _$_Score.fromJson(Map<String, dynamic> json) =>
      _$$_ScoreFromJson(json);

  @override
  final int up;
  @override
  final int down;
  @override
  final int total;

  @override
  String toString() {
    return 'Score(up: $up, down: $down, total: $total)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Score &&
            const DeepCollectionEquality().equals(other.up, up) &&
            const DeepCollectionEquality().equals(other.down, down) &&
            const DeepCollectionEquality().equals(other.total, total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(up),
      const DeepCollectionEquality().hash(down),
      const DeepCollectionEquality().hash(total));

  @JsonKey(ignore: true)
  @override
  _$$_ScoreCopyWith<_$_Score> get copyWith =>
      __$$_ScoreCopyWithImpl<_$_Score>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ScoreToJson(
      this,
    );
  }
}

abstract class _Score implements Score {
  const factory _Score(
      {required final int up,
      required final int down,
      required final int total}) = _$_Score;

  factory _Score.fromJson(Map<String, dynamic> json) = _$_Score.fromJson;

  @override
  int get up;
  @override
  int get down;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$_ScoreCopyWith<_$_Score> get copyWith =>
      throw _privateConstructorUsedError;
}
