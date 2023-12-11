import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

Widget? mergeSuffixIcons(InputDecoration? decoration, Widget? icon) {
  return decoration?.suffixIcon != null
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon,
            const SizedBox(width: 8),
            decoration!.suffixIcon!,
          ],
        )
      : icon;
}

class FilterTagTheme extends InheritedTheme {
  const FilterTagTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final FilterTagThemeData data;

  static FilterTagThemeData of(BuildContext context) => maybeOf(context)!;

  static FilterTagThemeData? maybeOf(BuildContext context) {
    final FilterTagTheme? result =
        context.dependOnInheritedWidgetOfExactType<FilterTagTheme>();
    return result?.data;
  }

  @override
  bool updateShouldNotify(FilterTagTheme oldWidget) =>
      data != oldWidget.data || data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FilterTagTheme(data: data, child: child);
}

class WrapperFilterConfig extends BuilderFilterConfig {
  WrapperFilterConfig({
    required this.wrapper,
    required this.unwrapper,
    required this.filters,
  }) : super(
          builder: (context, state) {
            QueryMap wrap(QueryMap tags) {
              return QueryMap.fromIterable(
                tags.entries.map((e) => MapEntry(wrapper(e.key), e.value)),
              );
            }

            QueryMap unwrap(QueryMap tags) {
              return QueryMap.fromIterable(
                tags.entries.map((e) => MapEntry(unwrapper(e.key), e.value)),
              );
            }

            return FilterList.from(
              state: FilterConfigState(
                tags: unwrap(state.tags),
                onChanged: (value) => state.onChanged(wrap(value)),
                onSubmit: state.onSubmit != null
                    ? (value) => state.onSubmit!(wrap(value))
                    : null,
                submitIcon: state.submitIcon,
              ),
              filters: filters,
            );
          },
        );

  final String Function(String tag) wrapper;
  final String Function(String tag) unwrapper;
  final List<FilterConfig> filters;
}

class PrimaryFilterConfig extends BuilderFilterConfig {
  PrimaryFilterConfig({
    required this.filter,
    this.filters = const [],
  }) : super(
          builder: (context, state) => PrimaryFilter(
            filter: filter,
            filters: filters,
            state: state,
          ),
        );

  final FilterTag filter;
  final List<FilterConfig> filters;
}

class NestedFilterTag extends BuilderFilterTag {
  NestedFilterTag({
    required super.tag,
    required QueryMap Function(String value) decode,
    required String Function(QueryMap tags) encode,
    super.name,
    required this.filters,
  }) : super(
          builder: (context, state) => FilterList(
            tags: decode(state.tags[tag] ?? ''),
            onChanged: (value) => state.onChanged(encode(value)),
            filters: filters,
          ),
        );

  final List<FilterConfig> filters;
}

class FilterList extends StatelessWidget {
  factory FilterList({
    Key? key,
    required QueryMap tags,
    required ValueSetter<QueryMap> onChanged,
    ValueSetter<QueryMap>? onSubmit,
    Widget? submitIcon,
    required List<FilterConfig> filters,
  }) =>
      FilterList.from(
        key: key,
        state: FilterConfigState(
          tags: tags,
          onChanged: onChanged,
          onSubmit: onSubmit,
          submitIcon: submitIcon,
        ),
        filters: filters,
      );

  const FilterList.from({
    super.key,
    required this.state,
    required this.filters,
  });

  final FilterConfigState state;
  final List<FilterConfig> filters;

  Widget buildFilter(BuildContext context, FilterConfig config) {
    FilterTagThemeData? theme = FilterTagTheme.maybeOf(context);
    return FilterTagTheme(
      data: theme ??
          const FilterTagThemeData(
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
      child: switch (config) {
        TextFilterTag() => TextFilter(state.apply(config)),
        NumberRangeFilterTag() => NumberRangeFilter(state.apply(config)),
        ChoiceFilterTag() => ChoiceFilter(state.apply(config)),
        ToggleFilterTag() => ToggleFilter(state.apply(config)),
        BuilderFilterTag() => BuilderTagFilter(state.apply(config)),
        BuilderFilterConfig() => config.builder(context, state),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    List<FilterConfig> filters = List.of(this.filters);

    for (final filter in filters) {
      if (filters.indexOf(filter) != 0) {
        children.add(const SizedBox(height: 16));
      }
      children.add(buildFilter(context, filter));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class PrimaryFilter extends StatelessWidget {
  const PrimaryFilter({
    super.key,
    required this.filter,
    required this.filters,
    required this.state,
  });

  final FilterTag filter;
  final List<FilterConfig> filters;
  final FilterConfigState state;

  @override
  Widget build(BuildContext context) {
    return SubFocusNode(builder: (context, focusNode) {
      return ExpandableTheme(
        data: ExpandableThemeData(
          iconColor: Theme.of(context).iconTheme.color,
        ),
        child: ExpandableNotifier(
          child: Builder(
            builder: (context) {
              ExpandableController expandableController =
                  ExpandableController.of(
                context,
                required: true,
                rebuildOnChange: false,
              )!;
              return SubListener(
                listenable: expandableController,
                listener: () {
                  if (expandableController.expanded) {
                    focusNode.unfocus();
                  } else {
                    focusNode.requestFocus();
                  }
                },
                builder: (context) {
                  bool hasChildren = filters.isNotEmpty;
                  FilterTagThemeData? theme = FilterTagTheme.maybeOf(context);
                  theme ??= const FilterTagThemeData();

                  Widget? submitIcon;
                  if (state.submitIcon != null) {
                    submitIcon = IconButton(
                      icon: state.submitIcon!,
                      onPressed: () => state.onSubmit?.call(state.tags),
                    );
                  }

                  theme = theme.copyWith(
                    primary: true,
                    decoration: theme.decoration.copyWith(
                      border: const UnderlineInputBorder(),
                      prefixIcon: hasChildren
                          ? ExpandableButton(child: ExpandableIcon())
                          : null,
                      suffixIcon: submitIcon,
                    ),
                    focusNode: focusNode,
                  );

                  return Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterTagTheme(
                          data: theme,
                          child: FilterList.from(
                            state: state,
                            filters: [filter],
                          ),
                        ),
                        if (hasChildren)
                          Flexible(
                            child: SingleChildScrollView(
                              child: Expandable(
                                collapsed: const SizedBox(),
                                expanded: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: FilterList.from(
                                    state: state,
                                    filters: filters,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    });
  }
}

class TextFilter extends StatefulWidget {
  const TextFilter(
    this.state, {
    super.key,
  });

  final FilterTagState<TextFilterTag> state;

  @override
  State<TextFilter> createState() => _TextFilterState();
}

class _TextFilterState extends State<TextFilter> {
  FilterTagState<TextFilterTag> get state => widget.state;

  late final TextEditingController _controller = TextEditingController(
    text: state.value,
  );

  @override
  void didUpdateWidget(TextFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.value != state.value &&
        state.value != _controller.text) {
      _controller.text = state.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    return TextFormField(
      key: Key('FilterList/${state.filter.tag}'),
      autofocus: theme.primary,
      focusNode: theme.focusNode,
      decoration: theme.decoration.copyWith(
        labelText: state.filter.name,
        suffixIcon: mergeSuffixIcons(
          theme.decoration,
          state.filter.icon,
        ),
      ),
      controller: _controller,
      onChanged: (value) => state.onChanged(value.isNotEmpty ? value : null),
      onFieldSubmitted: theme.primary ? state.onSubmit : null,
      textInputAction:
          theme.primary && state.onSubmit != null ? TextInputAction.done : null,
    );
  }
}

class NumberRangeFilter extends StatelessWidget {
  const NumberRangeFilter(
    this.state, {
    super.key,
  });

  final FilterTagState<NumberRangeFilterTag> state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => RangeDialog(
          title: state.filter.name != null ? Text(state.filter.name!) : null,
          value: state.value != null
              ? NumberRange.tryParse(state.value!)
              : state.filter.initial,
          division: 10,
          max: 100,
          onSubmit: (value) => state.onChanged(value?.toString()),
        ),
      ),
      child: ExcludeFocus(
        child: IgnorePointer(
          child: TextFormField(
            key: Key('FilterList/${state.filter.tag}:${state.value}'),
            decoration: theme.decoration.copyWith(
              labelText: state.filter.name,
              suffixIcon: mergeSuffixIcons(
                theme.decoration,
                state.filter.icon,
              ),
            ),
            readOnly: true,
            initialValue: state.value,
          ),
        ),
      ),
    );
  }
}

class ChoiceFilter extends StatelessWidget {
  const ChoiceFilter(
    this.state, {
    super.key,
  });

  final FilterTagState<ChoiceFilterTag> state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    String? value;
    if (state.filter.options.map((e) => e.value).contains(state.value)) {
      value = state.value;
    }
    return DropdownButtonFormField<String>(
      key: Key('FilterList/${state.filter.tag}'),
      value: value,
      decoration: theme.decoration.copyWith(labelText: state.filter.name),
      icon: state.filter.icon,
      isExpanded: true,
      items: [
        for (final option in state.filter.options)
          DropdownMenuItem(
            value: option.value,
            child: Text(option.title),
          ),
      ],
      onChanged: state.onChanged,
    );
  }
}

class ToggleFilter extends StatelessWidget {
  const ToggleFilter(
    this.state, {
    super.key,
  });

  final FilterTagState<ToggleFilterTag> state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    String enabled = state.filter.enabled;
    String? disabled = state.filter.disabled;
    bool tristate = disabled != null;

    bool? value;
    if (tristate) {
      if (state.value == enabled) {
        value = true;
      } else if (state.value == disabled) {
        value = null;
      } else {
        value = false;
      }
    } else {
      value = state.value == enabled;
    }

    return CheckboxFormField(
      key: Key('FilterList/${state.filter.tag}'),
      tristate: tristate,
      value: value,
      onChanged: (value) {
        if (value == null) {
          state.onChanged(state.filter.disabled);
        } else if (value) {
          state.onChanged(state.filter.enabled);
        } else {
          state.onChanged(null);
        }
      },
      label: state.filter.name,
      title: state.filter.description != null
          ? Text(state.filter.description!)
          : null,
      decoration: theme.decoration,
    );
  }
}

class BuilderTagFilter extends StatelessWidget {
  const BuilderTagFilter(
    this.state, {
    super.key,
  });

  final FilterTagState<BuilderFilterTag> state;

  @override
  Widget build(BuildContext context) => state.filter.builder(context, state);
}
