import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

/// Extensions on FilterController to use FilterTag configurations for getting/setting values
extension FilterControllerExtensions on ParamsController {
  /// Get a value using a FilterTag configuration
  V? getFilter<V>(FilterTag filter) => get<V>(filter.tag);

  /// Set a value using a FilterTag configuration
  void setFilter<V>(FilterTag filter, V? val) => set(filter.tag, val);

  /// Get an enum value using an EnumFilterTag configuration
  E? getFilterEnum<E extends Enum>(EnumFilterTag<E> filter) {
    final value = get<String>(filter.tag);
    if (value == null) return null;

    if (filter.valueMapper != null) {
      for (final enumValue in filter.values) {
        if (filter.valueMapper!(enumValue) == value) {
          return enumValue;
        }
      }
      return null;
    }

    return filter.values.asNameMap()[value];
  }

  /// Set an enum value using an EnumFilterTag configuration
  void setFilterEnum<E extends Enum>(EnumFilterTag<E> filter, E? val) {
    if (val == null) {
      set(filter.tag, null);
    } else {
      final mappedValue = filter.valueMapper?.call(val) ?? val.name;
      set(filter.tag, mappedValue);
    }
  }

  /// Get a boolean value using a ToggleFilterTag configuration
  bool? getFilterBool(ToggleFilterTag filter) {
    final val = query[filter.tag];
    if (val == null) return null;
    if (val == filter.enabled) return true;
    if (val == filter.disabled) return false;
    return null;
  }

  /// Set a boolean value using a ToggleFilterTag configuration
  void setFilterBool(ToggleFilterTag filter, bool? val) {
    if (val == null) {
      set(filter.tag, null);
    } else if (val) {
      set(filter.tag, filter.enabled);
    } else if (filter.disabled != null) {
      set(filter.tag, filter.disabled);
    } else {
      set(filter.tag, null);
    }
  }

  /// Get a NumberRange value using a NumberRangeFilterTag configuration
  NumberRange? getFilterRange(NumberRangeFilterTag filter) {
    final val = query[filter.tag];
    return val != null ? NumberRange.tryParse(val) : null;
  }

  /// Set a NumberRange value using a NumberRangeFilterTag configuration
  void setFilterRange(NumberRangeFilterTag filter, NumberRange? val) =>
      set(filter.tag, val?.toString());

  /// Get a Set<String> value using a MultiChoiceFilterTag configuration
  Set<String>? getFilterStringSet(MultiChoiceFilterTag filter) {
    return get<Set<String>>(filter.tag);
  }

  /// Set a Set<String> value using a MultiChoiceFilterTag configuration
  void setFilterStringSet(MultiChoiceFilterTag filter, Set<String>? val) {
    if (val == null) {
      set(filter.tag, null);
    } else {
      set(filter.tag, val);
    }
  }

  /// Get a Set<Enum> value using a MultiEnumFilterTag configuration
  Set<E>? getFilterEnumSet<E extends Enum>(MultiEnumFilterTag<E> filter) {
    final stringSet = getFilterStringSet(filter);
    if (stringSet == null) return null;

    Set<E>? result;
    for (final stringValue in stringSet) {
      E? enumValue;
      if (filter.valueMapper != null) {
        for (final e in filter.values) {
          if (filter.valueMapper!(e) == stringValue) {
            enumValue = e;
            break;
          }
        }
      } else {
        enumValue = filter.values.asNameMap()[stringValue];
      }
      if (enumValue != null) {
        result ??= {};
        result.add(enumValue);
      }
    }

    return result;
  }

  /// Set a Set<Enum> value using a MultiEnumFilterTag configuration
  void setFilterEnumSet<E extends Enum>(
    MultiEnumFilterTag<E> filter,
    Set<E>? val,
  ) {
    if (val == null) {
      set(filter.tag, null);
    } else {
      Set<String> stringSet = val
          .map((e) => filter.valueMapper?.call(e) ?? e.name)
          .toSet();
      set(filter.tag, stringSet);
    }
  }
}
