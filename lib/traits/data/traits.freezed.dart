// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Traits _$TraitsFromJson(Map<String, dynamic> json) {
  return _Traits.fromJson(json);
}

/// @nodoc
mixin _$Traits {
  int get id => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  List<String> get denylist => throw _privateConstructorUsedError;
  String get homeTags => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  int? get perPage => throw _privateConstructorUsedError;

  /// Serializes this Traits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Traits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TraitsCopyWith<Traits> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraitsCopyWith<$Res> {
  factory $TraitsCopyWith(Traits value, $Res Function(Traits) then) =
      _$TraitsCopyWithImpl<$Res, Traits>;
  @useResult
  $Res call({
    int id,
    int? userId,
    List<String> denylist,
    String homeTags,
    String? avatar,
    int? perPage,
  });
}

/// @nodoc
class _$TraitsCopyWithImpl<$Res, $Val extends Traits>
    implements $TraitsCopyWith<$Res> {
  _$TraitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Traits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? denylist = null,
    Object? homeTags = null,
    Object? avatar = freezed,
    Object? perPage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            denylist: null == denylist
                ? _value.denylist
                : denylist // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            homeTags: null == homeTags
                ? _value.homeTags
                : homeTags // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            perPage: freezed == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TraitsImplCopyWith<$Res> implements $TraitsCopyWith<$Res> {
  factory _$$TraitsImplCopyWith(
    _$TraitsImpl value,
    $Res Function(_$TraitsImpl) then,
  ) = __$$TraitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? userId,
    List<String> denylist,
    String homeTags,
    String? avatar,
    int? perPage,
  });
}

/// @nodoc
class __$$TraitsImplCopyWithImpl<$Res>
    extends _$TraitsCopyWithImpl<$Res, _$TraitsImpl>
    implements _$$TraitsImplCopyWith<$Res> {
  __$$TraitsImplCopyWithImpl(
    _$TraitsImpl _value,
    $Res Function(_$TraitsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Traits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? denylist = null,
    Object? homeTags = null,
    Object? avatar = freezed,
    Object? perPage = freezed,
  }) {
    return _then(
      _$TraitsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        denylist: null == denylist
            ? _value._denylist
            : denylist // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        homeTags: null == homeTags
            ? _value.homeTags
            : homeTags // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        perPage: freezed == perPage
            ? _value.perPage
            : perPage // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TraitsImpl implements _Traits {
  const _$TraitsImpl({
    required this.id,
    required this.userId,
    required final List<String> denylist,
    required this.homeTags,
    required this.avatar,
    required this.perPage,
  }) : _denylist = denylist;

  factory _$TraitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TraitsImplFromJson(json);

  @override
  final int id;
  @override
  final int? userId;
  final List<String> _denylist;
  @override
  List<String> get denylist {
    if (_denylist is EqualUnmodifiableListView) return _denylist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_denylist);
  }

  @override
  final String homeTags;
  @override
  final String? avatar;
  @override
  final int? perPage;

  @override
  String toString() {
    return 'Traits(id: $id, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraitsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._denylist, _denylist) &&
            (identical(other.homeTags, homeTags) ||
                other.homeTags == homeTags) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.perPage, perPage) || other.perPage == perPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    const DeepCollectionEquality().hash(_denylist),
    homeTags,
    avatar,
    perPage,
  );

  /// Create a copy of Traits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraitsImplCopyWith<_$TraitsImpl> get copyWith =>
      __$$TraitsImplCopyWithImpl<_$TraitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TraitsImplToJson(this);
  }
}

abstract class _Traits implements Traits {
  const factory _Traits({
    required final int id,
    required final int? userId,
    required final List<String> denylist,
    required final String homeTags,
    required final String? avatar,
    required final int? perPage,
  }) = _$TraitsImpl;

  factory _Traits.fromJson(Map<String, dynamic> json) = _$TraitsImpl.fromJson;

  @override
  int get id;
  @override
  int? get userId;
  @override
  List<String> get denylist;
  @override
  String get homeTags;
  @override
  String? get avatar;
  @override
  int? get perPage;

  /// Create a copy of Traits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraitsImplCopyWith<_$TraitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TraitsRequest _$TraitsRequestFromJson(Map<String, dynamic> json) {
  return _TraitsRequest.fromJson(json);
}

/// @nodoc
mixin _$TraitsRequest {
  int get identity => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  List<String> get denylist => throw _privateConstructorUsedError;
  String get homeTags => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  int? get perPage => throw _privateConstructorUsedError;

  /// Serializes this TraitsRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TraitsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TraitsRequestCopyWith<TraitsRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraitsRequestCopyWith<$Res> {
  factory $TraitsRequestCopyWith(
    TraitsRequest value,
    $Res Function(TraitsRequest) then,
  ) = _$TraitsRequestCopyWithImpl<$Res, TraitsRequest>;
  @useResult
  $Res call({
    int identity,
    int? userId,
    List<String> denylist,
    String homeTags,
    String? avatar,
    int? perPage,
  });
}

/// @nodoc
class _$TraitsRequestCopyWithImpl<$Res, $Val extends TraitsRequest>
    implements $TraitsRequestCopyWith<$Res> {
  _$TraitsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TraitsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = null,
    Object? userId = freezed,
    Object? denylist = null,
    Object? homeTags = null,
    Object? avatar = freezed,
    Object? perPage = freezed,
  }) {
    return _then(
      _value.copyWith(
            identity: null == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            denylist: null == denylist
                ? _value.denylist
                : denylist // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            homeTags: null == homeTags
                ? _value.homeTags
                : homeTags // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            perPage: freezed == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TraitsRequestImplCopyWith<$Res>
    implements $TraitsRequestCopyWith<$Res> {
  factory _$$TraitsRequestImplCopyWith(
    _$TraitsRequestImpl value,
    $Res Function(_$TraitsRequestImpl) then,
  ) = __$$TraitsRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int identity,
    int? userId,
    List<String> denylist,
    String homeTags,
    String? avatar,
    int? perPage,
  });
}

/// @nodoc
class __$$TraitsRequestImplCopyWithImpl<$Res>
    extends _$TraitsRequestCopyWithImpl<$Res, _$TraitsRequestImpl>
    implements _$$TraitsRequestImplCopyWith<$Res> {
  __$$TraitsRequestImplCopyWithImpl(
    _$TraitsRequestImpl _value,
    $Res Function(_$TraitsRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TraitsRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = null,
    Object? userId = freezed,
    Object? denylist = null,
    Object? homeTags = null,
    Object? avatar = freezed,
    Object? perPage = freezed,
  }) {
    return _then(
      _$TraitsRequestImpl(
        identity: null == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        denylist: null == denylist
            ? _value._denylist
            : denylist // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        homeTags: null == homeTags
            ? _value.homeTags
            : homeTags // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        perPage: freezed == perPage
            ? _value.perPage
            : perPage // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TraitsRequestImpl implements _TraitsRequest {
  const _$TraitsRequestImpl({
    required this.identity,
    this.userId,
    final List<String> denylist = const [],
    this.homeTags = '',
    this.avatar,
    this.perPage,
  }) : _denylist = denylist;

  factory _$TraitsRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TraitsRequestImplFromJson(json);

  @override
  final int identity;
  @override
  final int? userId;
  final List<String> _denylist;
  @override
  @JsonKey()
  List<String> get denylist {
    if (_denylist is EqualUnmodifiableListView) return _denylist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_denylist);
  }

  @override
  @JsonKey()
  final String homeTags;
  @override
  final String? avatar;
  @override
  final int? perPage;

  @override
  String toString() {
    return 'TraitsRequest(identity: $identity, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraitsRequestImpl &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._denylist, _denylist) &&
            (identical(other.homeTags, homeTags) ||
                other.homeTags == homeTags) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.perPage, perPage) || other.perPage == perPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    identity,
    userId,
    const DeepCollectionEquality().hash(_denylist),
    homeTags,
    avatar,
    perPage,
  );

  /// Create a copy of TraitsRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraitsRequestImplCopyWith<_$TraitsRequestImpl> get copyWith =>
      __$$TraitsRequestImplCopyWithImpl<_$TraitsRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TraitsRequestImplToJson(this);
  }
}

abstract class _TraitsRequest implements TraitsRequest {
  const factory _TraitsRequest({
    required final int identity,
    final int? userId,
    final List<String> denylist,
    final String homeTags,
    final String? avatar,
    final int? perPage,
  }) = _$TraitsRequestImpl;

  factory _TraitsRequest.fromJson(Map<String, dynamic> json) =
      _$TraitsRequestImpl.fromJson;

  @override
  int get identity;
  @override
  int? get userId;
  @override
  List<String> get denylist;
  @override
  String get homeTags;
  @override
  String? get avatar;
  @override
  int? get perPage;

  /// Create a copy of TraitsRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraitsRequestImplCopyWith<_$TraitsRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
