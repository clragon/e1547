// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 int get id; String get name; int? get avatarId; UserAbout? get about; UserStats? get stats;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarId, avatarId) || other.avatarId == avatarId)&&(identical(other.about, about) || other.about == about)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarId,about,stats);

@override
String toString() {
  return 'User(id: $id, name: $name, avatarId: $avatarId, about: $about, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? avatarId, UserAbout? about, UserStats? stats
});


$UserAboutCopyWith<$Res>? get about;$UserStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarId = freezed,Object? about = freezed,Object? stats = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarId: freezed == avatarId ? _self.avatarId : avatarId // ignore: cast_nullable_to_non_nullable
as int?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as UserAbout?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as UserStats?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAboutCopyWith<$Res>? get about {
    if (_self.about == null) {
    return null;
  }

  return $UserAboutCopyWith<$Res>(_self.about!, (value) {
    return _then(_self.copyWith(about: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $UserStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.name, required this.avatarId, required this.about, required this.stats});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  int id;
@override final  String name;
@override final  int? avatarId;
@override final  UserAbout? about;
@override final  UserStats? stats;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarId, avatarId) || other.avatarId == avatarId)&&(identical(other.about, about) || other.about == about)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarId,about,stats);

@override
String toString() {
  return 'User(id: $id, name: $name, avatarId: $avatarId, about: $about, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? avatarId, UserAbout? about, UserStats? stats
});


@override $UserAboutCopyWith<$Res>? get about;@override $UserStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarId = freezed,Object? about = freezed,Object? stats = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarId: freezed == avatarId ? _self.avatarId : avatarId // ignore: cast_nullable_to_non_nullable
as int?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as UserAbout?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as UserStats?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAboutCopyWith<$Res>? get about {
    if (_self.about == null) {
    return null;
  }

  return $UserAboutCopyWith<$Res>(_self.about!, (value) {
    return _then(_self.copyWith(about: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $UserStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$UserAbout {

 String? get bio; String? get comission;
/// Create a copy of UserAbout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserAboutCopyWith<UserAbout> get copyWith => _$UserAboutCopyWithImpl<UserAbout>(this as UserAbout, _$identity);

  /// Serializes this UserAbout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserAbout&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.comission, comission) || other.comission == comission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bio,comission);

@override
String toString() {
  return 'UserAbout(bio: $bio, comission: $comission)';
}


}

/// @nodoc
abstract mixin class $UserAboutCopyWith<$Res>  {
  factory $UserAboutCopyWith(UserAbout value, $Res Function(UserAbout) _then) = _$UserAboutCopyWithImpl;
@useResult
$Res call({
 String? bio, String? comission
});




}
/// @nodoc
class _$UserAboutCopyWithImpl<$Res>
    implements $UserAboutCopyWith<$Res> {
  _$UserAboutCopyWithImpl(this._self, this._then);

  final UserAbout _self;
  final $Res Function(UserAbout) _then;

/// Create a copy of UserAbout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bio = freezed,Object? comission = freezed,}) {
  return _then(_self.copyWith(
bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,comission: freezed == comission ? _self.comission : comission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserAbout implements UserAbout {
  const _UserAbout({required this.bio, required this.comission});
  factory _UserAbout.fromJson(Map<String, dynamic> json) => _$UserAboutFromJson(json);

@override final  String? bio;
@override final  String? comission;

/// Create a copy of UserAbout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserAboutCopyWith<_UserAbout> get copyWith => __$UserAboutCopyWithImpl<_UserAbout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserAboutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserAbout&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.comission, comission) || other.comission == comission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bio,comission);

@override
String toString() {
  return 'UserAbout(bio: $bio, comission: $comission)';
}


}

/// @nodoc
abstract mixin class _$UserAboutCopyWith<$Res> implements $UserAboutCopyWith<$Res> {
  factory _$UserAboutCopyWith(_UserAbout value, $Res Function(_UserAbout) _then) = __$UserAboutCopyWithImpl;
@override @useResult
$Res call({
 String? bio, String? comission
});




}
/// @nodoc
class __$UserAboutCopyWithImpl<$Res>
    implements _$UserAboutCopyWith<$Res> {
  __$UserAboutCopyWithImpl(this._self, this._then);

  final _UserAbout _self;
  final $Res Function(_UserAbout) _then;

/// Create a copy of UserAbout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bio = freezed,Object? comission = freezed,}) {
  return _then(_UserAbout(
bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,comission: freezed == comission ? _self.comission : comission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserStats {

 DateTime? get createdAt; String? get levelString; int? get favoriteCount; int? get postUpdateCount; int? get postUploadCount; int? get forumPostCount; int? get commentCount;
/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStatsCopyWith<UserStats> get copyWith => _$UserStatsCopyWithImpl<UserStats>(this as UserStats, _$identity);

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStats&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.levelString, levelString) || other.levelString == levelString)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.postUpdateCount, postUpdateCount) || other.postUpdateCount == postUpdateCount)&&(identical(other.postUploadCount, postUploadCount) || other.postUploadCount == postUploadCount)&&(identical(other.forumPostCount, forumPostCount) || other.forumPostCount == forumPostCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,levelString,favoriteCount,postUpdateCount,postUploadCount,forumPostCount,commentCount);

@override
String toString() {
  return 'UserStats(createdAt: $createdAt, levelString: $levelString, favoriteCount: $favoriteCount, postUpdateCount: $postUpdateCount, postUploadCount: $postUploadCount, forumPostCount: $forumPostCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class $UserStatsCopyWith<$Res>  {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) _then) = _$UserStatsCopyWithImpl;
@useResult
$Res call({
 DateTime? createdAt, String? levelString, int? favoriteCount, int? postUpdateCount, int? postUploadCount, int? forumPostCount, int? commentCount
});




}
/// @nodoc
class _$UserStatsCopyWithImpl<$Res>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._self, this._then);

  final UserStats _self;
  final $Res Function(UserStats) _then;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = freezed,Object? levelString = freezed,Object? favoriteCount = freezed,Object? postUpdateCount = freezed,Object? postUploadCount = freezed,Object? forumPostCount = freezed,Object? commentCount = freezed,}) {
  return _then(_self.copyWith(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,levelString: freezed == levelString ? _self.levelString : levelString // ignore: cast_nullable_to_non_nullable
as String?,favoriteCount: freezed == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int?,postUpdateCount: freezed == postUpdateCount ? _self.postUpdateCount : postUpdateCount // ignore: cast_nullable_to_non_nullable
as int?,postUploadCount: freezed == postUploadCount ? _self.postUploadCount : postUploadCount // ignore: cast_nullable_to_non_nullable
as int?,forumPostCount: freezed == forumPostCount ? _self.forumPostCount : forumPostCount // ignore: cast_nullable_to_non_nullable
as int?,commentCount: freezed == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserStats implements UserStats {
  const _UserStats({required this.createdAt, required this.levelString, required this.favoriteCount, required this.postUpdateCount, required this.postUploadCount, required this.forumPostCount, required this.commentCount});
  factory _UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);

@override final  DateTime? createdAt;
@override final  String? levelString;
@override final  int? favoriteCount;
@override final  int? postUpdateCount;
@override final  int? postUploadCount;
@override final  int? forumPostCount;
@override final  int? commentCount;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStatsCopyWith<_UserStats> get copyWith => __$UserStatsCopyWithImpl<_UserStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStats&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.levelString, levelString) || other.levelString == levelString)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.postUpdateCount, postUpdateCount) || other.postUpdateCount == postUpdateCount)&&(identical(other.postUploadCount, postUploadCount) || other.postUploadCount == postUploadCount)&&(identical(other.forumPostCount, forumPostCount) || other.forumPostCount == forumPostCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,levelString,favoriteCount,postUpdateCount,postUploadCount,forumPostCount,commentCount);

@override
String toString() {
  return 'UserStats(createdAt: $createdAt, levelString: $levelString, favoriteCount: $favoriteCount, postUpdateCount: $postUpdateCount, postUploadCount: $postUploadCount, forumPostCount: $forumPostCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$UserStatsCopyWith<$Res> implements $UserStatsCopyWith<$Res> {
  factory _$UserStatsCopyWith(_UserStats value, $Res Function(_UserStats) _then) = __$UserStatsCopyWithImpl;
@override @useResult
$Res call({
 DateTime? createdAt, String? levelString, int? favoriteCount, int? postUpdateCount, int? postUploadCount, int? forumPostCount, int? commentCount
});




}
/// @nodoc
class __$UserStatsCopyWithImpl<$Res>
    implements _$UserStatsCopyWith<$Res> {
  __$UserStatsCopyWithImpl(this._self, this._then);

  final _UserStats _self;
  final $Res Function(_UserStats) _then;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = freezed,Object? levelString = freezed,Object? favoriteCount = freezed,Object? postUpdateCount = freezed,Object? postUploadCount = freezed,Object? forumPostCount = freezed,Object? commentCount = freezed,}) {
  return _then(_UserStats(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,levelString: freezed == levelString ? _self.levelString : levelString // ignore: cast_nullable_to_non_nullable
as String?,favoriteCount: freezed == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int?,postUpdateCount: freezed == postUpdateCount ? _self.postUpdateCount : postUpdateCount // ignore: cast_nullable_to_non_nullable
as int?,postUploadCount: freezed == postUploadCount ? _self.postUploadCount : postUploadCount // ignore: cast_nullable_to_non_nullable
as int?,forumPostCount: freezed == forumPostCount ? _self.forumPostCount : forumPostCount // ignore: cast_nullable_to_non_nullable
as int?,commentCount: freezed == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
