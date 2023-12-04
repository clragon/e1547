// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

HistoriesSearch _$HistoriesSearchFromJson(Map<String, dynamic> json) {
  return _HistoriesSearch.fromJson(json);
}

/// @nodoc
mixin _$HistoriesSearch {
  DateTime? get date => throw _privateConstructorUsedError;
  Set<HistorySearchFilter> get searchFilters =>
      throw _privateConstructorUsedError;
  Set<HistoryTypeFilter> get typeFilters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HistoriesSearchCopyWith<HistoriesSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoriesSearchCopyWith<$Res> {
  factory $HistoriesSearchCopyWith(
          HistoriesSearch value, $Res Function(HistoriesSearch) then) =
      _$HistoriesSearchCopyWithImpl<$Res, HistoriesSearch>;
  @useResult
  $Res call(
      {DateTime? date,
      Set<HistorySearchFilter> searchFilters,
      Set<HistoryTypeFilter> typeFilters});
}

/// @nodoc
class _$HistoriesSearchCopyWithImpl<$Res, $Val extends HistoriesSearch>
    implements $HistoriesSearchCopyWith<$Res> {
  _$HistoriesSearchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? searchFilters = null,
    Object? typeFilters = null,
  }) {
    return _then(_value.copyWith(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchFilters: null == searchFilters
          ? _value.searchFilters
          : searchFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistorySearchFilter>,
      typeFilters: null == typeFilters
          ? _value.typeFilters
          : typeFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistoryTypeFilter>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoriesSearchImplCopyWith<$Res>
    implements $HistoriesSearchCopyWith<$Res> {
  factory _$$HistoriesSearchImplCopyWith(_$HistoriesSearchImpl value,
          $Res Function(_$HistoriesSearchImpl) then) =
      __$$HistoriesSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? date,
      Set<HistorySearchFilter> searchFilters,
      Set<HistoryTypeFilter> typeFilters});
}

/// @nodoc
class __$$HistoriesSearchImplCopyWithImpl<$Res>
    extends _$HistoriesSearchCopyWithImpl<$Res, _$HistoriesSearchImpl>
    implements _$$HistoriesSearchImplCopyWith<$Res> {
  __$$HistoriesSearchImplCopyWithImpl(
      _$HistoriesSearchImpl _value, $Res Function(_$HistoriesSearchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? searchFilters = null,
    Object? typeFilters = null,
  }) {
    return _then(_$HistoriesSearchImpl(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchFilters: null == searchFilters
          ? _value._searchFilters
          : searchFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistorySearchFilter>,
      typeFilters: null == typeFilters
          ? _value._typeFilters
          : typeFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistoryTypeFilter>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoriesSearchImpl extends _HistoriesSearch {
  const _$HistoriesSearchImpl(
      {this.date,
      required final Set<HistorySearchFilter> searchFilters,
      required final Set<HistoryTypeFilter> typeFilters})
      : _searchFilters = searchFilters,
        _typeFilters = typeFilters,
        super._();

  factory _$HistoriesSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoriesSearchImplFromJson(json);

  @override
  final DateTime? date;
  final Set<HistorySearchFilter> _searchFilters;
  @override
  Set<HistorySearchFilter> get searchFilters {
    if (_searchFilters is EqualUnmodifiableSetView) return _searchFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_searchFilters);
  }

  final Set<HistoryTypeFilter> _typeFilters;
  @override
  Set<HistoryTypeFilter> get typeFilters {
    if (_typeFilters is EqualUnmodifiableSetView) return _typeFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_typeFilters);
  }

  @override
  String toString() {
    return 'HistoriesSearch(date: $date, searchFilters: $searchFilters, typeFilters: $typeFilters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoriesSearchImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._searchFilters, _searchFilters) &&
            const DeepCollectionEquality()
                .equals(other._typeFilters, _typeFilters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      const DeepCollectionEquality().hash(_searchFilters),
      const DeepCollectionEquality().hash(_typeFilters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoriesSearchImplCopyWith<_$HistoriesSearchImpl> get copyWith =>
      __$$HistoriesSearchImplCopyWithImpl<_$HistoriesSearchImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoriesSearchImplToJson(
      this,
    );
  }
}

abstract class _HistoriesSearch extends HistoriesSearch {
  const factory _HistoriesSearch(
          {final DateTime? date,
          required final Set<HistorySearchFilter> searchFilters,
          required final Set<HistoryTypeFilter> typeFilters}) =
      _$HistoriesSearchImpl;
  const _HistoriesSearch._() : super._();

  factory _HistoriesSearch.fromJson(Map<String, dynamic> json) =
      _$HistoriesSearchImpl.fromJson;

  @override
  DateTime? get date;
  @override
  Set<HistorySearchFilter> get searchFilters;
  @override
  Set<HistoryTypeFilter> get typeFilters;
  @override
  @JsonKey(ignore: true)
  _$$HistoriesSearchImplCopyWith<_$HistoriesSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
