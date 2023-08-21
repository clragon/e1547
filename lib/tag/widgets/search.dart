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
    bool isDesktop = [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux
    ].contains(Theme.of(context).platform);

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
  late QueryMap tags = QueryMap.from(widget.tags);

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
      tags = QueryMap.from(widget.tags);
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

class SubTextValue extends StatelessWidget {
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
  final bool Function(String fromController, String fromValue)? shouldUpdate;

  @override
  Widget build(BuildContext context) {
    return SubTextEditingController(
      text: value,
      builder: (context, controller) => SubEffect(
        effect: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.text == value) return;
            if (shouldUpdate?.call(controller.text, value ?? '') ?? true) {
              controller.text = value ?? '';
            }
          });
          return null;
        },
        keys: [value],
        child: SubListener(
          listenable: controller,
          listener: () => WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged?.call(controller.text);
          }),
          builder: (context) => builder(context, controller),
        ),
      ),
    );
  }
}
