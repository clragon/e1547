import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

@immutable
sealed class FilterConfig {
  const FilterConfig();
}

@immutable
class FilterConfigState {
  const FilterConfigState({
    required this.tags,
    required this.onChanged,
    this.onSubmit,
    this.submitIcon,
  });

  final QueryMap tags;
  final ValueSetter<QueryMap> onChanged;
  final ValueSetter<QueryMap>? onSubmit;
  final Widget? submitIcon;
}

typedef BuilderFilterConfigBuilder =
    Widget Function(BuildContext context, FilterConfigState state);

class BuilderFilterConfig extends FilterConfig {
  const BuilderFilterConfig({required this.builder});

  final BuilderFilterConfigBuilder builder;
}

/// A filter in a filter list.
@immutable
sealed class FilterTag implements FilterConfig {
  const FilterTag({required this.tag, this.name});

  /// The tag of this filter.
  final String tag;

  /// The name of this filter.
  final String? name;
}

/// A filter that has a string as value.
///
/// This is represented by a text field.
class TextFilterTag extends FilterTag {
  const TextFilterTag({required super.tag, super.name, this.icon});

  /// The icon of this filter.
  final Widget? icon;
}

/// A filter that has a number as value.
///
/// This is represented by a number input field.
class NumberFilterTag extends FilterTag {
  const NumberFilterTag({
    required super.tag,
    super.name,
    this.min,
    this.max,
    this.icon,
  });

  /// The minimum value of the number.
  final int? min;

  /// The maximum value of the number.
  final int? max;

  /// The icon of this filter.
  final Widget? icon;
}

/// A filter that is tied to a number or range of numbers.
///
/// This is represented by a range dialog.
class NumberRangeFilterTag extends NumberFilterTag {
  const NumberRangeFilterTag({
    required super.tag,
    super.name,
    this.min,
    required this.max,
    this.division,
    this.initial,
    this.icon,
  });

  /// The minimum value of the number.
  ///
  /// Defaults to 0.
  @override
  final int? min;

  /// The maximum value of the number.
  @override
  final int max;

  /// The number of divisions of the slider.
  final int? division;

  /// The default value of the number.
  final NumberRange? initial;

  /// The icon of this filter.
  @override
  final Widget? icon;
}

/// An choice in a choice filter.
@immutable
class ChoiceFilterTagValue {
  const ChoiceFilterTagValue({required this.value, required this.name});

  /// The value of this choice. Must be unique.
  ///
  /// The default choice can be represented by null.
  final String? value;

  /// The name of this choice.
  final String? name;

  /// The title of this choice.
  String get title => name ?? value!;
}

/// A choice filter.
///
/// This is represented by a dropdown menu.
class ChoiceFilterTag extends FilterTag {
  const ChoiceFilterTag({
    required super.tag,
    super.name,
    required this.options,
    this.icon,
  });

  /// The options of this filter.
  /// Options must be unique.
  final List<ChoiceFilterTagValue> options;

  /// The icon of this filter.
  final Widget? icon;
}

class EnumFilterNullTagValue extends ChoiceFilterTagValue {
  const EnumFilterNullTagValue({String? name})
    : super(value: null, name: name ?? 'All');
}

/// A specialized choice filter for enums.
///
/// This provides type-safe enum handling with convenient get/set methods.
class EnumFilterTag<T extends Enum> extends ChoiceFilterTag {
  EnumFilterTag({
    required super.tag,
    super.name,
    required this.values,
    super.icon,
    this.valueMapper,
    this.nameMapper,
    this.undefinedOption,
  }) : super(
         options: [
           if (undefinedOption != null) undefinedOption,
           ...values.map((value) {
             return ChoiceFilterTagValue(
               value: valueMapper?.call(value) ?? value.name,
               name: nameMapper?.call(value) ?? value.name,
             );
           }),
         ],
       );

  /// The enum values for this filter
  final List<T> values;

  /// Optional function to map enum values to API values
  /// If not provided, uses enum.name as the value
  final String Function(T)? valueMapper;

  /// Optional function to map enum values to display names
  final String? Function(T)? nameMapper;

  /// Optional choice for the value `null`
  final EnumFilterNullTagValue? undefinedOption;
}

/// A toggle filter value.
/// This is represented by a checkbox.
///
/// A ToggleFilterValue can come in two forms:
/// - A two state toggle, where the tag is removed from the filter set when disabled.
/// - A three state toggle, where the tag is set to null when disabled.
class ToggleFilterTag extends FilterTag {
  const ToggleFilterTag({
    required super.tag,
    super.name,
    required this.enabled,
    this.disabled,
    this.description,
  });

  /// The value of the enabled state.
  final String enabled;

  /// The value of the disabled state.
  ///
  /// If this is null, the tag is removed from the filter set when disabled.
  /// If this is not null, the Toggle will have three states: enabled, disabled, and null.
  final String? disabled;

  /// A short description of this filter.
  /// Shown below the title.
  final String? description;
}

class BooleanFilterTag extends ToggleFilterTag {
  const BooleanFilterTag({
    required super.tag,
    super.name,
    super.description,
    bool tristate = false,
  }) : super(enabled: 'true', disabled: tristate ? 'false' : null);
}

extension FilterStateConfigExtension on FilterConfigState {
  FilterTagState<T> apply<T extends FilterTag>(T filter) {
    return FilterTagState<T>(config: this, filter: filter);
  }
}

@immutable
class FilterTagState<T extends FilterTag> {
  const FilterTagState({required this.config, required this.filter});

  static QueryMap _setOrRemove(QueryMap tags, String key, String? value) {
    tags = Map.of(tags);
    if (value == null) {
      tags.remove(key);
    } else {
      tags[key] = value;
    }
    return tags;
  }

  final FilterConfigState config;
  final T filter;

  QueryMap get tags => config.tags;
  String? get value => tags[filter.tag];
  ValueSetter<QueryMap> get onChangedTags => config.onChanged;
  ValueSetter<QueryMap>? get onSubmitTags => config.onSubmit;
  ValueSetter<String?> get onChanged =>
      ((value) => onChangedTags(_setOrRemove(tags, filter.tag, value)));
  ValueSetter<String?>? get onSubmit => onSubmitTags != null
      ? ((value) => onSubmitTags!(_setOrRemove(tags, filter.tag, value)))
      : null;

  @override
  String toString() => 'FilterState<$T>(tag: ${filter.tag}, value: $value)';

  @override
  bool operator ==(Object other) =>
      other is FilterTagState<T> &&
      filter.tag == other.filter.tag &&
      value == other.value;

  @override
  int get hashCode => Object.hash(filter, value);
}

typedef BuilderFilterTagBuilder =
    Widget Function(
      BuildContext context,
      FilterTagState<BuilderFilterTag> state,
    );

class BuilderFilterTag extends FilterTag {
  const BuilderFilterTag({
    required super.tag,
    super.name,
    required this.builder,
  });

  /// Returns the widget for this filter.
  final BuilderFilterTagBuilder builder;
}

@immutable
class FilterTagThemeData {
  const FilterTagThemeData({
    this.decoration = const InputDecoration(),
    this.focusNode,
    this.primary = false,
  });

  final InputDecoration decoration;
  final FocusNode? focusNode;
  final bool primary;

  FilterTagThemeData copyWith({
    InputDecoration? decoration,
    FocusNode? focusNode,
    bool? primary,
  }) {
    return FilterTagThemeData(
      decoration: decoration ?? this.decoration,
      focusNode: focusNode ?? this.focusNode,
      primary: primary ?? this.primary,
    );
  }
}
