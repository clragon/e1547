// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

 int get id; String? get file; String? get sample; String? get preview; int get width; int get height; String get ext; int get size; Map<String, String?>? get variants; Map<String, List<String>> get tags; int get uploaderId; DateTime get createdAt; DateTime? get updatedAt; VoteInfo get vote; bool get isDeleted; Rating get rating; int get favCount; bool get isFavorited; int get commentCount; String get description; List<String> get sources; List<int>? get pools; Relationships get relationships;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.sample, sample) || other.sample == sample)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.variants, variants)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favCount, favCount) || other.favCount == favCount)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.sources, sources)&&const DeepCollectionEquality().equals(other.pools, pools)&&(identical(other.relationships, relationships) || other.relationships == relationships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,file,sample,preview,width,height,ext,size,const DeepCollectionEquality().hash(variants),const DeepCollectionEquality().hash(tags),uploaderId,createdAt,updatedAt,vote,isDeleted,rating,favCount,isFavorited,commentCount,description,const DeepCollectionEquality().hash(sources),const DeepCollectionEquality().hash(pools),relationships]);

@override
String toString() {
  return 'Post(id: $id, file: $file, sample: $sample, preview: $preview, width: $width, height: $height, ext: $ext, size: $size, variants: $variants, tags: $tags, uploaderId: $uploaderId, createdAt: $createdAt, updatedAt: $updatedAt, vote: $vote, isDeleted: $isDeleted, rating: $rating, favCount: $favCount, isFavorited: $isFavorited, commentCount: $commentCount, description: $description, sources: $sources, pools: $pools, relationships: $relationships)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 int id, String? file, String? sample, String? preview, int width, int height, String ext, int size, Map<String, String?>? variants, Map<String, List<String>> tags, int uploaderId, DateTime createdAt, DateTime? updatedAt, VoteInfo vote, bool isDeleted, Rating rating, int favCount, bool isFavorited, int commentCount, String description, List<String> sources, List<int>? pools, Relationships relationships
});


$VoteInfoCopyWith<$Res> get vote;$RelationshipsCopyWith<$Res> get relationships;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? file = freezed,Object? sample = freezed,Object? preview = freezed,Object? width = null,Object? height = null,Object? ext = null,Object? size = null,Object? variants = freezed,Object? tags = null,Object? uploaderId = null,Object? createdAt = null,Object? updatedAt = freezed,Object? vote = null,Object? isDeleted = null,Object? rating = null,Object? favCount = null,Object? isFavorited = null,Object? commentCount = null,Object? description = null,Object? sources = null,Object? pools = freezed,Object? relationships = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String?,sample: freezed == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vote: null == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as VoteInfo,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating,favCount: null == favCount ? _self.favCount : favCount // ignore: cast_nullable_to_non_nullable
as int,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<String>,pools: freezed == pools ? _self.pools : pools // ignore: cast_nullable_to_non_nullable
as List<int>?,relationships: null == relationships ? _self.relationships : relationships // ignore: cast_nullable_to_non_nullable
as Relationships,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteInfoCopyWith<$Res> get vote {
  
  return $VoteInfoCopyWith<$Res>(_self.vote, (value) {
    return _then(_self.copyWith(vote: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RelationshipsCopyWith<$Res> get relationships {
  
  return $RelationshipsCopyWith<$Res>(_self.relationships, (value) {
    return _then(_self.copyWith(relationships: value));
  });
}
}



/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, required this.file, required this.sample, required this.preview, required this.width, required this.height, required this.ext, required this.size, required final  Map<String, String?>? variants, required final  Map<String, List<String>> tags, required this.uploaderId, required this.createdAt, required this.updatedAt, required this.vote, required this.isDeleted, required this.rating, required this.favCount, required this.isFavorited, required this.commentCount, required this.description, required final  List<String> sources, required final  List<int>? pools, required this.relationships}): _variants = variants,_tags = tags,_sources = sources,_pools = pools;
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  int id;
@override final  String? file;
@override final  String? sample;
@override final  String? preview;
@override final  int width;
@override final  int height;
@override final  String ext;
@override final  int size;
 final  Map<String, String?>? _variants;
@override Map<String, String?>? get variants {
  final value = _variants;
  if (value == null) return null;
  if (_variants is EqualUnmodifiableMapView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, List<String>> _tags;
@override Map<String, List<String>> get tags {
  if (_tags is EqualUnmodifiableMapView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tags);
}

@override final  int uploaderId;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override final  VoteInfo vote;
@override final  bool isDeleted;
@override final  Rating rating;
@override final  int favCount;
@override final  bool isFavorited;
@override final  int commentCount;
@override final  String description;
 final  List<String> _sources;
@override List<String> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

 final  List<int>? _pools;
@override List<int>? get pools {
  final value = _pools;
  if (value == null) return null;
  if (_pools is EqualUnmodifiableListView) return _pools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  Relationships relationships;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.sample, sample) || other.sample == sample)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._variants, _variants)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favCount, favCount) || other.favCount == favCount)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._sources, _sources)&&const DeepCollectionEquality().equals(other._pools, _pools)&&(identical(other.relationships, relationships) || other.relationships == relationships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,file,sample,preview,width,height,ext,size,const DeepCollectionEquality().hash(_variants),const DeepCollectionEquality().hash(_tags),uploaderId,createdAt,updatedAt,vote,isDeleted,rating,favCount,isFavorited,commentCount,description,const DeepCollectionEquality().hash(_sources),const DeepCollectionEquality().hash(_pools),relationships]);

@override
String toString() {
  return 'Post(id: $id, file: $file, sample: $sample, preview: $preview, width: $width, height: $height, ext: $ext, size: $size, variants: $variants, tags: $tags, uploaderId: $uploaderId, createdAt: $createdAt, updatedAt: $updatedAt, vote: $vote, isDeleted: $isDeleted, rating: $rating, favCount: $favCount, isFavorited: $isFavorited, commentCount: $commentCount, description: $description, sources: $sources, pools: $pools, relationships: $relationships)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 int id, String? file, String? sample, String? preview, int width, int height, String ext, int size, Map<String, String?>? variants, Map<String, List<String>> tags, int uploaderId, DateTime createdAt, DateTime? updatedAt, VoteInfo vote, bool isDeleted, Rating rating, int favCount, bool isFavorited, int commentCount, String description, List<String> sources, List<int>? pools, Relationships relationships
});


@override $VoteInfoCopyWith<$Res> get vote;@override $RelationshipsCopyWith<$Res> get relationships;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? file = freezed,Object? sample = freezed,Object? preview = freezed,Object? width = null,Object? height = null,Object? ext = null,Object? size = null,Object? variants = freezed,Object? tags = null,Object? uploaderId = null,Object? createdAt = null,Object? updatedAt = freezed,Object? vote = null,Object? isDeleted = null,Object? rating = null,Object? favCount = null,Object? isFavorited = null,Object? commentCount = null,Object? description = null,Object? sources = null,Object? pools = freezed,Object? relationships = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String?,sample: freezed == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,variants: freezed == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vote: null == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as VoteInfo,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating,favCount: null == favCount ? _self.favCount : favCount // ignore: cast_nullable_to_non_nullable
as int,isFavorited: null == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<String>,pools: freezed == pools ? _self._pools : pools // ignore: cast_nullable_to_non_nullable
as List<int>?,relationships: null == relationships ? _self.relationships : relationships // ignore: cast_nullable_to_non_nullable
as Relationships,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteInfoCopyWith<$Res> get vote {
  
  return $VoteInfoCopyWith<$Res>(_self.vote, (value) {
    return _then(_self.copyWith(vote: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RelationshipsCopyWith<$Res> get relationships {
  
  return $RelationshipsCopyWith<$Res>(_self.relationships, (value) {
    return _then(_self.copyWith(relationships: value));
  });
}
}


/// @nodoc
mixin _$Relationships {

 int? get parentId; bool get hasChildren; bool? get hasActiveChildren; List<int> get children;
/// Create a copy of Relationships
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelationshipsCopyWith<Relationships> get copyWith => _$RelationshipsCopyWithImpl<Relationships>(this as Relationships, _$identity);

  /// Serializes this Relationships to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Relationships&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.hasChildren, hasChildren) || other.hasChildren == hasChildren)&&(identical(other.hasActiveChildren, hasActiveChildren) || other.hasActiveChildren == hasActiveChildren)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,parentId,hasChildren,hasActiveChildren,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'Relationships(parentId: $parentId, hasChildren: $hasChildren, hasActiveChildren: $hasActiveChildren, children: $children)';
}


}

/// @nodoc
abstract mixin class $RelationshipsCopyWith<$Res>  {
  factory $RelationshipsCopyWith(Relationships value, $Res Function(Relationships) _then) = _$RelationshipsCopyWithImpl;
@useResult
$Res call({
 int? parentId, bool hasChildren, bool? hasActiveChildren, List<int> children
});




}
/// @nodoc
class _$RelationshipsCopyWithImpl<$Res>
    implements $RelationshipsCopyWith<$Res> {
  _$RelationshipsCopyWithImpl(this._self, this._then);

  final Relationships _self;
  final $Res Function(Relationships) _then;

/// Create a copy of Relationships
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? parentId = freezed,Object? hasChildren = null,Object? hasActiveChildren = freezed,Object? children = null,}) {
  return _then(_self.copyWith(
parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,hasChildren: null == hasChildren ? _self.hasChildren : hasChildren // ignore: cast_nullable_to_non_nullable
as bool,hasActiveChildren: freezed == hasActiveChildren ? _self.hasActiveChildren : hasActiveChildren // ignore: cast_nullable_to_non_nullable
as bool?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Relationships implements Relationships {
  const _Relationships({required this.parentId, required this.hasChildren, required this.hasActiveChildren, required final  List<int> children}): _children = children;
  factory _Relationships.fromJson(Map<String, dynamic> json) => _$RelationshipsFromJson(json);

@override final  int? parentId;
@override final  bool hasChildren;
@override final  bool? hasActiveChildren;
 final  List<int> _children;
@override List<int> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of Relationships
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelationshipsCopyWith<_Relationships> get copyWith => __$RelationshipsCopyWithImpl<_Relationships>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelationshipsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Relationships&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.hasChildren, hasChildren) || other.hasChildren == hasChildren)&&(identical(other.hasActiveChildren, hasActiveChildren) || other.hasActiveChildren == hasActiveChildren)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,parentId,hasChildren,hasActiveChildren,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'Relationships(parentId: $parentId, hasChildren: $hasChildren, hasActiveChildren: $hasActiveChildren, children: $children)';
}


}

/// @nodoc
abstract mixin class _$RelationshipsCopyWith<$Res> implements $RelationshipsCopyWith<$Res> {
  factory _$RelationshipsCopyWith(_Relationships value, $Res Function(_Relationships) _then) = __$RelationshipsCopyWithImpl;
@override @useResult
$Res call({
 int? parentId, bool hasChildren, bool? hasActiveChildren, List<int> children
});




}
/// @nodoc
class __$RelationshipsCopyWithImpl<$Res>
    implements _$RelationshipsCopyWith<$Res> {
  __$RelationshipsCopyWithImpl(this._self, this._then);

  final _Relationships _self;
  final $Res Function(_Relationships) _then;

/// Create a copy of Relationships
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? parentId = freezed,Object? hasChildren = null,Object? hasActiveChildren = freezed,Object? children = null,}) {
  return _then(_Relationships(
parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,hasChildren: null == hasChildren ? _self.hasChildren : hasChildren // ignore: cast_nullable_to_non_nullable
as bool,hasActiveChildren: freezed == hasActiveChildren ? _self.hasActiveChildren : hasActiveChildren // ignore: cast_nullable_to_non_nullable
as bool?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
