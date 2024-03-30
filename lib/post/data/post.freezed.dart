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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  int get id => throw _privateConstructorUsedError;
  String? get file => throw _privateConstructorUsedError;
  String? get sample => throw _privateConstructorUsedError;
  String? get preview => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  String get ext => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  Map<String, String>? get variants => throw _privateConstructorUsedError;
  Map<String, List<String>> get tags => throw _privateConstructorUsedError;
  int get uploaderId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  VoteInfo get vote => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  Rating get rating => throw _privateConstructorUsedError;
  int get favCount =>
      throw _privateConstructorUsedError; // turn into class with bool isFavorited?
  bool get isFavorited => throw _privateConstructorUsedError;
  int? get commentCount => throw _privateConstructorUsedError;
  bool? get hasComments => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get sources => throw _privateConstructorUsedError;
  List<int>? get pools => throw _privateConstructorUsedError;
  Relationships get relationships => throw _privateConstructorUsedError;

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
      String? file,
      String? sample,
      String? preview,
      int width,
      int height,
      String ext,
      int size,
      Map<String, String>? variants,
      Map<String, List<String>> tags,
      int uploaderId,
      DateTime createdAt,
      DateTime? updatedAt,
      VoteInfo vote,
      bool isDeleted,
      Rating rating,
      int favCount,
      bool isFavorited,
      int? commentCount,
      bool? hasComments,
      String description,
      List<String> sources,
      List<int>? pools,
      Relationships relationships});

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
    Object? file = freezed,
    Object? sample = freezed,
    Object? preview = freezed,
    Object? width = null,
    Object? height = null,
    Object? ext = null,
    Object? size = null,
    Object? variants = freezed,
    Object? tags = null,
    Object? uploaderId = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? vote = null,
    Object? isDeleted = null,
    Object? rating = null,
    Object? favCount = null,
    Object? isFavorited = null,
    Object? commentCount = freezed,
    Object? hasComments = freezed,
    Object? description = null,
    Object? sources = null,
    Object? pools = freezed,
    Object? relationships = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as String?,
      sample: freezed == sample
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as String?,
      preview: freezed == preview
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as String?,
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
      variants: freezed == variants
          ? _value.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      uploaderId: null == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vote: null == vote
          ? _value.vote
          : vote // ignore: cast_nullable_to_non_nullable
              as VoteInfo,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: null == favCount
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      hasComments: freezed == hasComments
          ? _value.hasComments
          : hasComments // ignore: cast_nullable_to_non_nullable
              as bool?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: freezed == pools
          ? _value.pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      relationships: null == relationships
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
    ) as $Val);
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
      String? file,
      String? sample,
      String? preview,
      int width,
      int height,
      String ext,
      int size,
      Map<String, String>? variants,
      Map<String, List<String>> tags,
      int uploaderId,
      DateTime createdAt,
      DateTime? updatedAt,
      VoteInfo vote,
      bool isDeleted,
      Rating rating,
      int favCount,
      bool isFavorited,
      int? commentCount,
      bool? hasComments,
      String description,
      List<String> sources,
      List<int>? pools,
      Relationships relationships});

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
    Object? file = freezed,
    Object? sample = freezed,
    Object? preview = freezed,
    Object? width = null,
    Object? height = null,
    Object? ext = null,
    Object? size = null,
    Object? variants = freezed,
    Object? tags = null,
    Object? uploaderId = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? vote = null,
    Object? isDeleted = null,
    Object? rating = null,
    Object? favCount = null,
    Object? isFavorited = null,
    Object? commentCount = freezed,
    Object? hasComments = freezed,
    Object? description = null,
    Object? sources = null,
    Object? pools = freezed,
    Object? relationships = null,
  }) {
    return _then(_$PostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as String?,
      sample: freezed == sample
          ? _value.sample
          : sample // ignore: cast_nullable_to_non_nullable
              as String?,
      preview: freezed == preview
          ? _value.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as String?,
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
      variants: freezed == variants
          ? _value._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      uploaderId: null == uploaderId
          ? _value.uploaderId
          : uploaderId // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vote: null == vote
          ? _value.vote
          : vote // ignore: cast_nullable_to_non_nullable
              as VoteInfo,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating,
      favCount: null == favCount
          ? _value.favCount
          : favCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorited: null == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
      hasComments: freezed == hasComments
          ? _value.hasComments
          : hasComments // ignore: cast_nullable_to_non_nullable
              as bool?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pools: freezed == pools
          ? _value._pools
          : pools // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      relationships: null == relationships
          ? _value.relationships
          : relationships // ignore: cast_nullable_to_non_nullable
              as Relationships,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl(
      {required this.id,
      required this.file,
      required this.sample,
      required this.preview,
      required this.width,
      required this.height,
      required this.ext,
      required this.size,
      required final Map<String, String>? variants,
      required final Map<String, List<String>> tags,
      required this.uploaderId,
      required this.createdAt,
      required this.updatedAt,
      required this.vote,
      required this.isDeleted,
      required this.rating,
      required this.favCount,
      required this.isFavorited,
      required this.commentCount,
      required this.hasComments,
      required this.description,
      required final List<String> sources,
      required final List<int>? pools,
      required this.relationships})
      : _variants = variants,
        _tags = tags,
        _sources = sources,
        _pools = pools;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final int id;
  @override
  final String? file;
  @override
  final String? sample;
  @override
  final String? preview;
  @override
  final int width;
  @override
  final int height;
  @override
  final String ext;
  @override
  final int size;
  final Map<String, String>? _variants;
  @override
  Map<String, String>? get variants {
    final value = _variants;
    if (value == null) return null;
    if (_variants is EqualUnmodifiableMapView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, List<String>> _tags;
  @override
  Map<String, List<String>> get tags {
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tags);
  }

  @override
  final int uploaderId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final VoteInfo vote;
  @override
  final bool isDeleted;
  @override
  final Rating rating;
  @override
  final int favCount;
// turn into class with bool isFavorited?
  @override
  final bool isFavorited;
  @override
  final int? commentCount;
  @override
  final bool? hasComments;
  @override
  final String description;
  final List<String> _sources;
  @override
  List<String> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  final List<int>? _pools;
  @override
  List<int>? get pools {
    final value = _pools;
    if (value == null) return null;
    if (_pools is EqualUnmodifiableListView) return _pools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Relationships relationships;

  @override
  String toString() {
    return 'Post(id: $id, file: $file, sample: $sample, preview: $preview, width: $width, height: $height, ext: $ext, size: $size, variants: $variants, tags: $tags, uploaderId: $uploaderId, createdAt: $createdAt, updatedAt: $updatedAt, vote: $vote, isDeleted: $isDeleted, rating: $rating, favCount: $favCount, isFavorited: $isFavorited, commentCount: $commentCount, hasComments: $hasComments, description: $description, sources: $sources, pools: $pools, relationships: $relationships)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.sample, sample) || other.sample == sample) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.ext, ext) || other.ext == ext) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.uploaderId, uploaderId) ||
                other.uploaderId == uploaderId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.vote, vote) || other.vote == vote) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.favCount, favCount) ||
                other.favCount == favCount) &&
            (identical(other.isFavorited, isFavorited) ||
                other.isFavorited == isFavorited) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.hasComments, hasComments) ||
                other.hasComments == hasComments) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            const DeepCollectionEquality().equals(other._pools, _pools) &&
            (identical(other.relationships, relationships) ||
                other.relationships == relationships));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        file,
        sample,
        preview,
        width,
        height,
        ext,
        size,
        const DeepCollectionEquality().hash(_variants),
        const DeepCollectionEquality().hash(_tags),
        uploaderId,
        createdAt,
        updatedAt,
        vote,
        isDeleted,
        rating,
        favCount,
        isFavorited,
        commentCount,
        hasComments,
        description,
        const DeepCollectionEquality().hash(_sources),
        const DeepCollectionEquality().hash(_pools),
        relationships
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

abstract class _Post implements Post {
  const factory _Post(
      {required final int id,
      required final String? file,
      required final String? sample,
      required final String? preview,
      required final int width,
      required final int height,
      required final String ext,
      required final int size,
      required final Map<String, String>? variants,
      required final Map<String, List<String>> tags,
      required final int uploaderId,
      required final DateTime createdAt,
      required final DateTime? updatedAt,
      required final VoteInfo vote,
      required final bool isDeleted,
      required final Rating rating,
      required final int favCount,
      required final bool isFavorited,
      required final int? commentCount,
      required final bool? hasComments,
      required final String description,
      required final List<String> sources,
      required final List<int>? pools,
      required final Relationships relationships}) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  int get id;
  @override
  String? get file;
  @override
  String? get sample;
  @override
  String? get preview;
  @override
  int get width;
  @override
  int get height;
  @override
  String get ext;
  @override
  int get size;
  @override
  Map<String, String>? get variants;
  @override
  Map<String, List<String>> get tags;
  @override
  int get uploaderId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  VoteInfo get vote;
  @override
  bool get isDeleted;
  @override
  Rating get rating;
  @override
  int get favCount;
  @override // turn into class with bool isFavorited?
  bool get isFavorited;
  @override
  int? get commentCount;
  @override
  bool? get hasComments;
  @override
  String get description;
  @override
  List<String> get sources;
  @override
  List<int>? get pools;
  @override
  Relationships get relationships;
  @override
  @JsonKey(ignore: true)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
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
  bool operator ==(Object other) {
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
