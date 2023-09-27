// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ClientSyncStatus _$ClientSyncStatusFromJson(Map<String, dynamic> json) {
  return _ClientSyncStatus.fromJson(json);
}

/// @nodoc
mixin _$ClientSyncStatus {
  DenyListSyncStatus? get denyList => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClientSyncStatusCopyWith<ClientSyncStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientSyncStatusCopyWith<$Res> {
  factory $ClientSyncStatusCopyWith(
          ClientSyncStatus value, $Res Function(ClientSyncStatus) then) =
      _$ClientSyncStatusCopyWithImpl<$Res, ClientSyncStatus>;
  @useResult
  $Res call({DenyListSyncStatus? denyList});
}

/// @nodoc
class _$ClientSyncStatusCopyWithImpl<$Res, $Val extends ClientSyncStatus>
    implements $ClientSyncStatusCopyWith<$Res> {
  _$ClientSyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? denyList = freezed,
  }) {
    return _then(_value.copyWith(
      denyList: freezed == denyList
          ? _value.denyList
          : denyList // ignore: cast_nullable_to_non_nullable
              as DenyListSyncStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientSyncStatusImplCopyWith<$Res>
    implements $ClientSyncStatusCopyWith<$Res> {
  factory _$$ClientSyncStatusImplCopyWith(_$ClientSyncStatusImpl value,
          $Res Function(_$ClientSyncStatusImpl) then) =
      __$$ClientSyncStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DenyListSyncStatus? denyList});
}

/// @nodoc
class __$$ClientSyncStatusImplCopyWithImpl<$Res>
    extends _$ClientSyncStatusCopyWithImpl<$Res, _$ClientSyncStatusImpl>
    implements _$$ClientSyncStatusImplCopyWith<$Res> {
  __$$ClientSyncStatusImplCopyWithImpl(_$ClientSyncStatusImpl _value,
      $Res Function(_$ClientSyncStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? denyList = freezed,
  }) {
    return _then(_$ClientSyncStatusImpl(
      denyList: freezed == denyList
          ? _value.denyList
          : denyList // ignore: cast_nullable_to_non_nullable
              as DenyListSyncStatus?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientSyncStatusImpl implements _ClientSyncStatus {
  const _$ClientSyncStatusImpl({this.denyList});

  factory _$ClientSyncStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientSyncStatusImplFromJson(json);

  @override
  final DenyListSyncStatus? denyList;

  @override
  String toString() {
    return 'ClientSyncStatus(denyList: $denyList)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientSyncStatusImpl &&
            (identical(other.denyList, denyList) ||
                other.denyList == denyList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, denyList);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientSyncStatusImplCopyWith<_$ClientSyncStatusImpl> get copyWith =>
      __$$ClientSyncStatusImplCopyWithImpl<_$ClientSyncStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientSyncStatusImplToJson(
      this,
    );
  }
}

abstract class _ClientSyncStatus implements ClientSyncStatus {
  const factory _ClientSyncStatus({final DenyListSyncStatus? denyList}) =
      _$ClientSyncStatusImpl;

  factory _ClientSyncStatus.fromJson(Map<String, dynamic> json) =
      _$ClientSyncStatusImpl.fromJson;

  @override
  DenyListSyncStatus? get denyList;
  @override
  @JsonKey(ignore: true)
  _$$ClientSyncStatusImplCopyWith<_$ClientSyncStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
