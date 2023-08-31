import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class SearchPromptFloationgActionButton extends StatelessWidget {
  const SearchPromptFloationgActionButton({
    super.key,
    required this.tags,
    this.onChanged,
    this.onSubmit,
    required this.filters,
  });

  final QueryMap tags;
  final ValueSetter<QueryMap>? onChanged;
  final ValueSetter<QueryMap>? onSubmit;
  final List<FilterConfig> filters;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Theme.of(context).isDesktop;
    return SubValue<PromptActionController>(
      create: () =>
          isDesktop ? DialogActionController() : SheetActionController(),
      keys: [isDesktop],
      builder: (context, actionController) => PromptFloatingActionButton(
        controller: actionController,
        builder: (context, actionController) => ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: isDesktop ? 600 : 0,
          ),
          child: Material(
            child: PromptFilterList(
              tags: tags,
              onChanged: onChanged,
              onSubmit: onSubmit,
              showSubmit: isDesktop,
              filters: filters,
              controller: actionController,
            ),
          ),
        ),
        icon: const Icon(Icons.search),
      ),
    );
  }
}

class PromptFilterList extends StatefulWidget {
  const PromptFilterList({
    super.key,
    required this.tags,
    this.onChanged,
    this.onSubmit,
    required this.filters,
    required this.controller,
    this.showSubmit,
  });

  final QueryMap tags;
  final ValueSetter<QueryMap>? onChanged;
  final ValueSetter<QueryMap>? onSubmit;
  final List<FilterConfig> filters;
  final ActionController controller;
  final bool? showSubmit;

  @override
  State<PromptFilterList> createState() => _PromptFilterListState();
}

class _PromptFilterListState extends State<PromptFilterList> {
  late QueryMap tags = QueryMap(widget.tags);

  void onChanged(QueryMap tags) {
    setState(() => this.tags = tags);
    widget.onChanged?.call(tags);
  }

  void onSubmit(QueryMap tags) {
    onChanged(tags);
    widget.onSubmit?.call(tags);
  }

  @override
  void didUpdateWidget(PromptFilterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      tags = QueryMap(widget.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.setAction(() => onSubmit(tags));
        });
        return null;
      },
      keys: const [],
      child: FilterList(
        tags: tags,
        onChanged: onChanged,
        onSubmit: (tags) {
          onChanged(tags);
          widget.controller.action!();
        },
        submitIcon:
            (widget.showSubmit ?? false) ? const Icon(Icons.search) : null,
        filters: widget.filters,
      ),
    );
  }
}

typedef SubTextValueShouldUpdate = bool Function(
    String fromController, String fromValue);

class SubTextValue extends StatefulWidget {
  const SubTextValue({
    super.key,
    required this.value,
    this.onChanged,
    required this.builder,
    this.shouldUpdate,
  });

  final String? value;
  final ValueSetter<String>? onChanged;
  final Widget Function(BuildContext context, TextEditingController controller)
      builder;
  final SubTextValueShouldUpdate? shouldUpdate;

  @override
  State<SubTextValue> createState() => _SubTextValueState();
}

class _SubTextValueState extends State<SubTextValue> {
  late TextEditingController controller =
      TextEditingController(text: widget.value);
  bool controllerUpdate = false;
  bool valueUpdate = false;
  bool isUpdating = false;

  void updateController() {
    if (controllerUpdate) return;
    controllerUpdate = true;
    processUpdate();
  }

  void updateValue() {
    if (valueUpdate) return;
    valueUpdate = true;
    processUpdate();
  }

  void processUpdate() {
    if (isUpdating) return;
    isUpdating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String controllerText = controller.text;
      String value = widget.value ?? '';
      if (controllerUpdate) {
        SubTextValueShouldUpdate? shouldUpdate = widget.shouldUpdate;
        shouldUpdate ??= (a, b) => a != b;
        if (shouldUpdate(controllerText, value)) {
          controllerText = value;
        }
      } else if (valueUpdate) {
        widget.onChanged?.call(controllerText);
      }

      controllerUpdate = false;
      valueUpdate = false;
      isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        updateController();
        return null;
      },
      keys: [widget.value],
      child: SubListener(
        listenable: controller,
        listener: () => updateValue(),
        builder: (context) => widget.builder(context, controller),
      ),
    );
  }
}
