import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';

/// Extensions on FilterController to use FilterTag configurations for getting/setting values
extension FilterControllerExtensions<T> on FilterController<T> {
  /// Get a value using a FilterTag configuration
  V? getFilter<V>(FilterTag filter) => get<V>(filter.tag);

  /// Set a value using a FilterTag configuration
  void setFilter<V>(FilterTag filter, V? val) => set(filter.tag, val);

  /// Get an enum value using an EnumFilterTag configuration
  E? getFilterEnum<E extends Enum>(EnumFilterTag<E> filter) =>
      getEnum<E>(filter.tag, filter.values);

  /// Set an enum value using an EnumFilterTag configuration
  void setFilterEnum<E extends Enum>(EnumFilterTag<E> filter, E? val) =>
      set(filter.tag, val);

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
}
