import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class SearchPromptFloatingActionButton extends StatelessWidget {
  const SearchPromptFloatingActionButton({
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
      create: () => PromptActionController(),
      builder: (context, actionController) => PromptFloatingActionButton(
        controller: actionController,
        builder: (context) => Material(
          child: PromptFilterList(
            tags: tags,
            onChanged: onChanged,
            onSubmit: onSubmit,
            submitIcon: isDesktop ? const Icon(Icons.search) : null,
            filters: filters,
            controller: actionController,
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
    this.controller,
    this.submitIcon,
  });

  final QueryMap tags;
  final ValueSetter<QueryMap>? onChanged;
  final ValueSetter<QueryMap>? onSubmit;
  final List<FilterConfig> filters;
  final ActionController? controller;
  final Widget? submitIcon;

  @override
  State<PromptFilterList> createState() => _PromptFilterListState();
}

class _PromptFilterListState extends State<PromptFilterList> {
  late QueryMap tags = Map.of(widget.tags);

  void onChanged(QueryMap tags) {
    setState(() => this.tags = tags);
    widget.onChanged?.call(tags);
  }

  void onSubmit(QueryMap tags) {
    setState(() => this.tags = tags);
    onChanged(tags);
    widget.onSubmit?.call(tags);
  }

  @override
  void didUpdateWidget(PromptFilterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      tags = Map.of(widget.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller?.setAction(() => onSubmit(tags));
        });
        return null;
      },
      keys: [widget.controller],
      child: FilterList(
        tags: tags,
        onChanged: onChanged,
        onSubmit: (value) =>
            widget.controller?.action?.call() ?? onSubmit(value),
        submitIcon: widget.submitIcon,
        filters: widget.filters,
      ),
    );
  }
}

typedef SubTextValueShouldUpdate =
    bool Function(String fromController, String fromValue);

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
  late final controller = TextEditingController(text: widget.value);

  bool controllerUpdate = false;
  bool valueUpdate = false;
  bool isUpdating = false;
  String? _lastSentValue;

  void updateController() {
    if (!controllerUpdate) {
      controllerUpdate = true;
      processUpdate();
    }
  }

  void updateValue() {
    if (!valueUpdate) {
      valueUpdate = true;
      processUpdate();
    }
  }

  void processUpdate() {
    if (isUpdating) return;
    isUpdating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controllerUpdate) _applyIncomingValue();
      if (valueUpdate) _sendOutgoingValue();

      controllerUpdate = false;
      valueUpdate = false;
      isUpdating = false;
    });
  }

  void _applyIncomingValue() {
    final incoming = widget.value ?? '';
    final local = controller.text;

    if (_lastSentValue == incoming) {
      _lastSentValue = null;
      return;
    }

    final shouldUpdate = widget.shouldUpdate ?? (a, b) => a != b;
    if (!shouldUpdate(local, incoming)) return;
    if (local != controller.text) return;

    final oldValue = controller.value;
    controller.value = TextEditingValue(
      text: incoming,
      selection: _calculateNewSelection(oldValue, incoming),
    );
  }

  void _sendOutgoingValue() {
    final local = controller.text;
    _lastSentValue = local;
    widget.onChanged?.call(local);
  }

  TextSelection _calculateNewSelection(
    TextEditingValue oldValue,
    String newText,
  ) {
    final baseOffset = oldValue.selection.baseOffset;
    final extentOffset = oldValue.selection.extentOffset;

    if (baseOffset < 0 || extentOffset < 0) {
      return TextSelection.collapsed(offset: newText.length);
    }

    return TextSelection(
      baseOffset: baseOffset.clamp(0, newText.length),
      extentOffset: extentOffset.clamp(0, newText.length),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        listener: updateValue,
        builder: (context) => widget.builder(context, controller),
      ),
    );
  }
}
