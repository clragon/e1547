// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

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
  @JsonKey(includeFromJson: false, includeToJson: false)
  VoteStatus get voteStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
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
      @JsonKey(includeFromJson: false, includeToJson: false)
      VoteStatus voteStatus});

  $PostSourceFileCopyWith<$Res> get fileRaw;
  $PostPreviewFileCopyWith<$Res> get preview;
  $PostSampleFileCopyWith<$Res> get sample;
  $ScoreCopyWith<$Res> get score;
  $FlagsCopyWith<$Res> get flags;
  $RelationshipsCopyWith<$Res> get relationships;
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? fileRaw = null,
    Object? preview = null,
    Object? sample = null,
    Object? score = null,
    Object? tags = null,
    Object? lockedTags = freezed,
    Object? changeSeq = freezed,
    Object? flags = null,
    Object? rating = null,
    Object? favCount = null,
    Object? sources = null,
    Object? pools = null,
    Object? relationships = null,
    Object? approverId = freezed,
    Object? uploaderId = null,
    Object? description = null,
    Object? commentCount = null,
    Object? isFavorited = null,
    Object? hasNotes = null,
    Object? duration = freezed,
    Object? voteStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileRaw: null == fileRaw
          ? _value.fileRaw
          : fileRaw // ignore: cast_nullable_to_non_nullable
              as PostSourceFile,
      preview: null == preview
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as PostPreviewFile,
      sample: null == sample
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as PostSampleFile,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as Score,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lockedTags: freezed == lockedTags
          ? _value.lockedTags
          : lockedTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      changeSeq: freezed == changeSeq
          ? _value.changeSeq
          : changeSeq // ignore: cast_nullable_to_non_nullable
              as int?,
      flags: null == flags
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Flags,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: null == favCount
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: null == pools
          ? _value.pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>,
      relationships: null == relationships
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
      approverId: freezed == approverId
          ? _value.approverId
          : approverId // ignore: cast_nullable_to_non_nullable
              as int?,
      uploaderId: null == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNotes: null == hasNotes
          ? _value.hasNotes
          : hasNotes // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      voteStatus: null == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PostSourceFileCopyWith<$Res> get fileRaw {
    return $PostSourceFileCopyWith<$Res>(_value.fileRaw, (value) {
      return _then(_value.copyWith(fileRaw: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PostPreviewFileCopyWith<$Res> get preview {
    return $PostPreviewFileCopyWith<$Res>(_value.preview, (value) {
      return _then(_value.copyWith(preview: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PostSampleFileCopyWith<$Res> get sample {
    return $PostSampleFileCopyWith<$Res>(_value.sample, (value) {
      return _then(_value.copyWith(sample: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ScoreCopyWith<$Res> get score {
    return $ScoreCopyWith<$Res>(_value.score, (value) {
      return _then(_value.copyWith(score: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $FlagsCopyWith<$Res> get flags {
    return $FlagsCopyWith<$Res>(_value.flags, (value) {
      return _then(_value.copyWith(flags: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $RelationshipsCopyWith<$Res> get relationships {
    return $RelationshipsCopyWith<$Res>(_value.relationships, (value) {
      return _then(_value.copyWith(relationships: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
          _$PostImpl value, $Res Function(_$PostImpl) then) =
      __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
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
      @JsonKey(includeFromJson: false, includeToJson: false)
      VoteStatus voteStatus});

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
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? fileRaw = null,
    Object? preview = null,
    Object? sample = null,
    Object? score = null,
    Object? tags = null,
    Object? lockedTags = freezed,
    Object? changeSeq = freezed,
    Object? flags = null,
    Object? rating = null,
    Object? favCount = null,
    Object? sources = null,
    Object? pools = null,
    Object? relationships = null,
    Object? approverId = freezed,
    Object? uploaderId = null,
    Object? description = null,
    Object? commentCount = null,
    Object? isFavorited = null,
    Object? hasNotes = null,
    Object? duration = freezed,
    Object? voteStatus = null,
  }) {
    return _then(_$PostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fileRaw: null == fileRaw
          ? _value.fileRaw
          : fileRaw // ignore: cast_nullable_to_non_nullable
              as PostSourceFile,
      preview: null == preview
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as PostPreviewFile,
      sample: null == sample
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as PostSampleFile,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as Score,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lockedTags: freezed == lockedTags
          ? _value._lockedTags
          : lockedTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      changeSeq: freezed == changeSeq
          ? _value.changeSeq
          : changeSeq // ignore: cast_nullable_to_non_nullable
              as int?,
      flags: null == flags
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Flags,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: null == favCount
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: null == pools
          ? _value._pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>,
      relationships: null == relationships
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
      approverId: freezed == approverId
          ? _value.approverId
          : approverId // ignore: cast_nullable_to_non_nullable
              as int?,
      uploaderId: null == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNotes: null == hasNotes
          ? _value.hasNotes
          : hasNotes // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      voteStatus: null == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl extends _Post {
  const _$PostImpl(
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
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.voteStatus = VoteStatus.unknown})
      : _tags = tags,
        _lockedTags = lockedTags,
        _sources = sources,
        _pools = pools,
        super._();

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

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
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tags);
  }

  final List<String>? _lockedTags;
  @override
  List<String>? get lockedTags {
    final value = _lockedTags;
    if (value == null) return null;
    if (_lockedTags is EqualUnmodifiableListView) return _lockedTags;
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
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  final List<int> _pools;
  @override
  List<int> get pools {
    if (_pools is EqualUnmodifiableListView) return _pools;
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final VoteStatus voteStatus;

  @override
  String toString() {
    return 'Post(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, fileRaw: $fileRaw, preview: $preview, sample: $sample, score: $score, tags: $tags, lockedTags: $lockedTags, changeSeq: $changeSeq, flags: $flags, rating: $rating, favCount: $favCount, sources: $sources, pools: $pools, relationships: $relationships, approverId: $approverId, uploaderId: $uploaderId, description: $description, commentCount: $commentCount, isFavorited: $isFavorited, hasNotes: $hasNotes, duration: $duration, voteStatus: $voteStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.fileRaw, fileRaw) || other.fileRaw == fileRaw) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            (identical(other.sample, sample) || other.sample == sample) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._lockedTags, _lockedTags) &&
            (identical(other.changeSeq, changeSeq) ||
                other.changeSeq == changeSeq) &&
            (identical(other.flags, flags) || other.flags == flags) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.favCount, favCount) ||
                other.favCount == favCount) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            const DeepCollectionEquality().equals(other._pools, _pools) &&
            (identical(other.relationships, relationships) ||
                other.relationships == relationships) &&
            (identical(other.approverId, approverId) ||
                other.approverId == approverId) &&
            (identical(other.uploaderId, uploaderId) ||
                other.uploaderId == uploaderId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isFavorited, isFavorited) ||
                other.isFavorited == isFavorited) &&
            (identical(other.hasNotes, hasNotes) ||
                other.hasNotes == hasNotes) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.voteStatus, voteStatus) ||
                other.voteStatus == voteStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        fileRaw,
        preview,
        sample,
        score,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_lockedTags),
        changeSeq,
        flags,
        rating,
        favCount,
        const DeepCollectionEquality().hash(_sources),
        const DeepCollectionEquality().hash(_pools),
        relationships,
        approverId,
        uploaderId,
        description,
        commentCount,
        isFavorited,
        hasNotes,
        duration,
        voteStatus
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(
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
      @JsonKey(includeFromJson: false, includeToJson: false)
      final VoteStatus voteStatus}) = _$PostImpl;
  const _Post._() : super._();

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

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
  @JsonKey(includeFromJson: false, includeToJson: false)
  VoteStatus get voteStatus;
  @override
  @JsonKey(ignore: true)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
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
      _$PostPreviewFileCopyWithImpl<$Res, PostPreviewFile>;
  @useResult
  $Res call({int width, int height, String? url});
}

/// @nodoc
class _$PostPreviewFileCopyWithImpl<$Res, $Val extends PostPreviewFile>
    implements $PostPreviewFileCopyWith<$Res> {
  _$PostPreviewFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostPreviewFileImplCopyWith<$Res>
    implements $PostPreviewFileCopyWith<$Res> {
  factory _$$PostPreviewFileImplCopyWith(_$PostPreviewFileImpl value,
          $Res Function(_$PostPreviewFileImpl) then) =
      __$$PostPreviewFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int width, int height, String? url});
}

/// @nodoc
class __$$PostPreviewFileImplCopyWithImpl<$Res>
    extends _$PostPreviewFileCopyWithImpl<$Res, _$PostPreviewFileImpl>
    implements _$$PostPreviewFileImplCopyWith<$Res> {
  __$$PostPreviewFileImplCopyWithImpl(
      _$PostPreviewFileImpl _value, $Res Function(_$PostPreviewFileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? url = freezed,
  }) {
    return _then(_$PostPreviewFileImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostPreviewFileImpl implements _PostPreviewFile {
  const _$PostPreviewFileImpl(
      {required this.width, required this.height, required this.url});

  factory _$PostPreviewFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostPreviewFileImplFromJson(json);

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
            other is _$PostPreviewFileImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, width, height, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostPreviewFileImplCopyWith<_$PostPreviewFileImpl> get copyWith =>
      __$$PostPreviewFileImplCopyWithImpl<_$PostPreviewFileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostPreviewFileImplToJson(
      this,
    );
  }
}

abstract class _PostPreviewFile implements PostPreviewFile {
  const factory _PostPreviewFile(
      {required final int width,
      required final int height,
      required final String? url}) = _$PostPreviewFileImpl;

  factory _PostPreviewFile.fromJson(Map<String, dynamic> json) =
      _$PostPreviewFileImpl.fromJson;

  @override
  int get width;
  @override
  int get height;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$PostPreviewFileImplCopyWith<_$PostPreviewFileImpl> get copyWith =>
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
      _$PostSampleFileCopyWithImpl<$Res, PostSampleFile>;
  @useResult
  $Res call({bool has, int height, int width, String? url});
}

/// @nodoc
class _$PostSampleFileCopyWithImpl<$Res, $Val extends PostSampleFile>
    implements $PostSampleFileCopyWith<$Res> {
  _$PostSampleFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? has = null,
    Object? height = null,
    Object? width = null,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      has: null == has
          ? _value.has
          : has // ignore: cast_nullable_to_non_nullable
              as bool,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostSampleFileImplCopyWith<$Res>
    implements $PostSampleFileCopyWith<$Res> {
  factory _$$PostSampleFileImplCopyWith(_$PostSampleFileImpl value,
          $Res Function(_$PostSampleFileImpl) then) =
      __$$PostSampleFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool has, int height, int width, String? url});
}

/// @nodoc
class __$$PostSampleFileImplCopyWithImpl<$Res>
    extends _$PostSampleFileCopyWithImpl<$Res, _$PostSampleFileImpl>
    implements _$$PostSampleFileImplCopyWith<$Res> {
  __$$PostSampleFileImplCopyWithImpl(
      _$PostSampleFileImpl _value, $Res Function(_$PostSampleFileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? has = null,
    Object? height = null,
    Object? width = null,
    Object? url = freezed,
  }) {
    return _then(_$PostSampleFileImpl(
      has: null == has
          ? _value.has
          : has // ignore: cast_nullable_to_non_nullable
              as bool,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostSampleFileImpl implements _PostSampleFile {
  const _$PostSampleFileImpl(
      {required this.has,
      required this.height,
      required this.width,
      required this.url});

  factory _$PostSampleFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostSampleFileImplFromJson(json);

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
            other is _$PostSampleFileImpl &&
            (identical(other.has, has) || other.has == has) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, has, height, width, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostSampleFileImplCopyWith<_$PostSampleFileImpl> get copyWith =>
      __$$PostSampleFileImplCopyWithImpl<_$PostSampleFileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostSampleFileImplToJson(
      this,
    );
  }
}

abstract class _PostSampleFile implements PostSampleFile {
  const factory _PostSampleFile(
      {required final bool has,
      required final int height,
      required final int width,
      required final String? url}) = _$PostSampleFileImpl;

  factory _PostSampleFile.fromJson(Map<String, dynamic> json) =
      _$PostSampleFileImpl.fromJson;

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
  _$$PostSampleFileImplCopyWith<_$PostSampleFileImpl> get copyWith =>
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
      _$PostSourceFileCopyWithImpl<$Res, PostSourceFile>;
  @useResult
  $Res call(
      {int width, int height, String ext, int size, String md5, String? url});
}

/// @nodoc
class _$PostSourceFileCopyWithImpl<$Res, $Val extends PostSourceFile>
    implements $PostSourceFileCopyWith<$Res> {
  _$PostSourceFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? ext = null,
    Object? size = null,
    Object? md5 = null,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      ext: null == ext
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      md5: null == md5
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostSourceFileImplCopyWith<$Res>
    implements $PostSourceFileCopyWith<$Res> {
  factory _$$PostSourceFileImplCopyWith(_$PostSourceFileImpl value,
          $Res Function(_$PostSourceFileImpl) then) =
      __$$PostSourceFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int width, int height, String ext, int size, String md5, String? url});
}

/// @nodoc
class __$$PostSourceFileImplCopyWithImpl<$Res>
    extends _$PostSourceFileCopyWithImpl<$Res, _$PostSourceFileImpl>
    implements _$$PostSourceFileImplCopyWith<$Res> {
  __$$PostSourceFileImplCopyWithImpl(
      _$PostSourceFileImpl _value, $Res Function(_$PostSourceFileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? ext = null,
    Object? size = null,
    Object? md5 = null,
    Object? url = freezed,
  }) {
    return _then(_$PostSourceFileImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      ext: null == ext
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      md5: null == md5
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostSourceFileImpl implements _PostSourceFile {
  const _$PostSourceFileImpl(
      {required this.width,
      required this.height,
      required this.ext,
      required this.size,
      required this.md5,
      required this.url});

  factory _$PostSourceFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostSourceFileImplFromJson(json);

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
            other is _$PostSourceFileImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.ext, ext) || other.ext == ext) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.md5, md5) || other.md5 == md5) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, width, height, ext, size, md5, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostSourceFileImplCopyWith<_$PostSourceFileImpl> get copyWith =>
      __$$PostSourceFileImplCopyWithImpl<_$PostSourceFileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostSourceFileImplToJson(
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
      required final String? url}) = _$PostSourceFileImpl;

  factory _PostSourceFile.fromJson(Map<String, dynamic> json) =
      _$PostSourceFileImpl.fromJson;

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
  _$$PostSourceFileImplCopyWith<_$PostSourceFileImpl> get copyWith =>
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
      _$FlagsCopyWithImpl<$Res, Flags>;
  @useResult
  $Res call(
      {bool pending,
      bool flagged,
      bool noteLocked,
      bool statusLocked,
      bool ratingLocked,
      bool deleted});
}

/// @nodoc
class _$FlagsCopyWithImpl<$Res, $Val extends Flags>
    implements $FlagsCopyWith<$Res> {
  _$FlagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pending = null,
    Object? flagged = null,
    Object? noteLocked = null,
    Object? statusLocked = null,
    Object? ratingLocked = null,
    Object? deleted = null,
  }) {
    return _then(_value.copyWith(
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as bool,
      flagged: null == flagged
          ? _value.flagged
          : flagged // ignore: cast_nullable_to_non_nullable
              as bool,
      noteLocked: null == noteLocked
          ? _value.noteLocked
          : noteLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      statusLocked: null == statusLocked
          ? _value.statusLocked
          : statusLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingLocked: null == ratingLocked
          ? _value.ratingLocked
          : ratingLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlagsImplCopyWith<$Res> implements $FlagsCopyWith<$Res> {
  factory _$$FlagsImplCopyWith(
          _$FlagsImpl value, $Res Function(_$FlagsImpl) then) =
      __$$FlagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool pending,
      bool flagged,
      bool noteLocked,
      bool statusLocked,
      bool ratingLocked,
      bool deleted});
}

/// @nodoc
class __$$FlagsImplCopyWithImpl<$Res>
    extends _$FlagsCopyWithImpl<$Res, _$FlagsImpl>
    implements _$$FlagsImplCopyWith<$Res> {
  __$$FlagsImplCopyWithImpl(
      _$FlagsImpl _value, $Res Function(_$FlagsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pending = null,
    Object? flagged = null,
    Object? noteLocked = null,
    Object? statusLocked = null,
    Object? ratingLocked = null,
    Object? deleted = null,
  }) {
    return _then(_$FlagsImpl(
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as bool,
      flagged: null == flagged
          ? _value.flagged
          : flagged // ignore: cast_nullable_to_non_nullable
              as bool,
      noteLocked: null == noteLocked
          ? _value.noteLocked
          : noteLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      statusLocked: null == statusLocked
          ? _value.statusLocked
          : statusLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingLocked: null == ratingLocked
          ? _value.ratingLocked
          : ratingLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      deleted: null == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlagsImpl implements _Flags {
  const _$FlagsImpl(
      {required this.pending,
      required this.flagged,
      required this.noteLocked,
      required this.statusLocked,
      required this.ratingLocked,
      required this.deleted});

  factory _$FlagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlagsImplFromJson(json);

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
            other is _$FlagsImpl &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.flagged, flagged) || other.flagged == flagged) &&
            (identical(other.noteLocked, noteLocked) ||
                other.noteLocked == noteLocked) &&
            (identical(other.statusLocked, statusLocked) ||
                other.statusLocked == statusLocked) &&
            (identical(other.ratingLocked, ratingLocked) ||
                other.ratingLocked == ratingLocked) &&
            (identical(other.deleted, deleted) || other.deleted == deleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pending, flagged, noteLocked,
      statusLocked, ratingLocked, deleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlagsImplCopyWith<_$FlagsImpl> get copyWith =>
      __$$FlagsImplCopyWithImpl<_$FlagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlagsImplToJson(
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
      required final bool deleted}) = _$FlagsImpl;

  factory _Flags.fromJson(Map<String, dynamic> json) = _$FlagsImpl.fromJson;

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
  _$$FlagsImplCopyWith<_$FlagsImpl> get copyWith =>
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
      _$RelationshipsCopyWithImpl<$Res, Relationships>;
  @useResult
  $Res call(
      {int? parentId,
      bool hasChildren,
      bool hasActiveChildren,
      List<int> children});
}

/// @nodoc
class _$RelationshipsCopyWithImpl<$Res, $Val extends Relationships>
    implements $RelationshipsCopyWith<$Res> {
  _$RelationshipsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? hasChildren = null,
    Object? hasActiveChildren = null,
    Object? children = null,
  }) {
    return _then(_value.copyWith(
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasChildren: null == hasChildren
          ? _value.hasChildren
          : hasChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChildren: null == hasActiveChildren
          ? _value.hasActiveChildren
          : hasActiveChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelationshipsImplCopyWith<$Res>
    implements $RelationshipsCopyWith<$Res> {
  factory _$$RelationshipsImplCopyWith(
          _$RelationshipsImpl value, $Res Function(_$RelationshipsImpl) then) =
      __$$RelationshipsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? parentId,
      bool hasChildren,
      bool hasActiveChildren,
      List<int> children});
}

/// @nodoc
class __$$RelationshipsImplCopyWithImpl<$Res>
    extends _$RelationshipsCopyWithImpl<$Res, _$RelationshipsImpl>
    implements _$$RelationshipsImplCopyWith<$Res> {
  __$$RelationshipsImplCopyWithImpl(
      _$RelationshipsImpl _value, $Res Function(_$RelationshipsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? hasChildren = null,
    Object? hasActiveChildren = null,
    Object? children = null,
  }) {
    return _then(_$RelationshipsImpl(
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      hasChildren: null == hasChildren
          ? _value.hasChildren
          : hasChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      hasActiveChildren: null == hasActiveChildren
          ? _value.hasActiveChildren
          : hasActiveChildren // ignore: cast_nullable_to_non_nullable
              as bool,
      children: null == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RelationshipsImpl implements _Relationships {
  const _$RelationshipsImpl(
      {required this.parentId,
      required this.hasChildren,
      required this.hasActiveChildren,
      required final List<int> children})
      : _children = children;

  factory _$RelationshipsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelationshipsImplFromJson(json);

  @override
  final int? parentId;
  @override
  final bool hasChildren;
  @override
  final bool hasActiveChildren;
  final List<int> _children;
  @override
  List<int> get children {
    if (_children is EqualUnmodifiableListView) return _children;
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
            other is _$RelationshipsImpl &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.hasChildren, hasChildren) ||
                other.hasChildren == hasChildren) &&
            (identical(other.hasActiveChildren, hasActiveChildren) ||
                other.hasActiveChildren == hasActiveChildren) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, parentId, hasChildren,
      hasActiveChildren, const DeepCollectionEquality().hash(_children));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RelationshipsImplCopyWith<_$RelationshipsImpl> get copyWith =>
      __$$RelationshipsImplCopyWithImpl<_$RelationshipsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelationshipsImplToJson(
      this,
    );
  }
}

abstract class _Relationships implements Relationships {
  const factory _Relationships(
      {required final int? parentId,
      required final bool hasChildren,
      required final bool hasActiveChildren,
      required final List<int> children}) = _$RelationshipsImpl;

  factory _Relationships.fromJson(Map<String, dynamic> json) =
      _$RelationshipsImpl.fromJson;

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
  _$$RelationshipsImplCopyWith<_$RelationshipsImpl> get copyWith =>
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
      _$ScoreCopyWithImpl<$Res, Score>;
  @useResult
  $Res call({int up, int down, int total});
}

/// @nodoc
class _$ScoreCopyWithImpl<$Res, $Val extends Score>
    implements $ScoreCopyWith<$Res> {
  _$ScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? up = null,
    Object? down = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      up: null == up
          ? _value.up
          : up // ignore: cast_nullable_to_non_nullable
              as int,
      down: null == down
          ? _value.down
          : down // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoreImplCopyWith<$Res> implements $ScoreCopyWith<$Res> {
  factory _$$ScoreImplCopyWith(
          _$ScoreImpl value, $Res Function(_$ScoreImpl) then) =
      __$$ScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int up, int down, int total});
}

/// @nodoc
class __$$ScoreImplCopyWithImpl<$Res>
    extends _$ScoreCopyWithImpl<$Res, _$ScoreImpl>
    implements _$$ScoreImplCopyWith<$Res> {
  __$$ScoreImplCopyWithImpl(
      _$ScoreImpl _value, $Res Function(_$ScoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? up = null,
    Object? down = null,
    Object? total = null,
  }) {
    return _then(_$ScoreImpl(
      up: null == up
          ? _value.up
          : up // ignore: cast_nullable_to_non_nullable
              as int,
      down: null == down
          ? _value.down
          : down // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreImpl implements _Score {
  const _$ScoreImpl(
      {required this.up, required this.down, required this.total});

  factory _$ScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreImplFromJson(json);

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
            other is _$ScoreImpl &&
            (identical(other.up, up) || other.up == up) &&
            (identical(other.down, down) || other.down == down) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, up, down, total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreImplCopyWith<_$ScoreImpl> get copyWith =>
      __$$ScoreImplCopyWithImpl<_$ScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreImplToJson(
      this,
    );
  }
}

abstract class _Score implements Score {
  const factory _Score(
      {required final int up,
      required final int down,
      required final int total}) = _$ScoreImpl;

  factory _Score.fromJson(Map<String, dynamic> json) = _$ScoreImpl.fromJson;

  @override
  int get up;
  @override
  int get down;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$ScoreImplCopyWith<_$ScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
