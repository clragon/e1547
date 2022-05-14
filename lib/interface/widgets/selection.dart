import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef SelectionChanged<T> = void Function(Set<T> selections);

class SelectionLayoutData<T> extends InheritedWidget {
  final Set<T> selections;
  final List<T> items;
  final SelectionChanged<T> onChanged;

  const SelectionLayoutData({
    required super.child,
    required this.selections,
    required this.onChanged,
    required this.items,
  });

  @override
  bool updateShouldNotify(covariant SelectionLayoutData oldWidget) =>
      (oldWidget.selections != selections || oldWidget.onChanged != onChanged);
}

class SelectionLayout<T> extends StatefulWidget {
  final Widget child;
  final List<T>? items;
  final bool enabled;

  const SelectionLayout({
    required this.child,
    required this.items,
    this.enabled = true,
  });

  static SelectionLayoutData<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>();
  }

  @override
  State<SelectionLayout<T>> createState() => _SelectionLayoutState<T>();
}

class _SelectionLayoutState<T> extends State<SelectionLayout<T>> {
  Set<T> selections = {};

  @override
  void didUpdateWidget(covariant SelectionLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      Set<T> updated = Set.from(selections);
      updated.removeWhere(
          (element) => !(widget.items?.contains(element) ?? false));
      onSelectionChanged(updated);
    }
  }

  void onSelectionChanged(Set<T> selections) {
    setState(() {
      this.selections = selections;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return WillPopScope(
      onWillPop: () async {
        if (selections.isNotEmpty) {
          onSelectionChanged({});
          return false;
        } else {
          return true;
        }
      },
      child: SelectionLayoutData<T>(
        items: widget.items ?? [],
        selections: selections,
        onChanged: onSelectionChanged,
        child: widget.child,
      ),
    );
  }
}

class SelectionAppBar<T> extends StatelessWidget with AppBarBuilderWidget {
  final List<Widget> Function(
      BuildContext context, SelectionLayoutData<T> layoutData) actionBuilder;
  final Widget Function(
      BuildContext context, SelectionLayoutData<T> layoutData)? titleBuilder;
  @override
  final PreferredSizeWidget child;

  const SelectionAppBar({
    required this.child,
    required this.actionBuilder,
    this.titleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.of<T>(context);
    return CrossFade.builder(
      showChild: layoutData != null && layoutData.selections.isNotEmpty,
      builder: (context) => DefaultAppBar(
        title: titleBuilder?.call(context, layoutData!) ??
            Text('${layoutData!.selections.length} items'),
        leading: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => layoutData!.onChanged({}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => layoutData!.onChanged(layoutData.items.toSet()),
          ),
          ...actionBuilder(context, layoutData!),
        ],
      ),
      secondChild: child,
    );
  }
}

class SelectionItemOverlay<T> extends StatelessWidget {
  final Widget child;
  final T item;
  final EdgeInsets? padding;

  const SelectionItemOverlay({
    required this.child,
    required this.item,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.of<T>(context);

    if (layoutData != null) {
      void select() {
        Set<T> updated = Set.from(layoutData.selections);
        if (updated.contains(item)) {
          updated.remove(item);
        } else {
          updated.add(item);
        }
        layoutData.onChanged(updated);
      }

      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: layoutData.selections.isNotEmpty ? select : null,
              onLongPress: select,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: defaultAnimationDuration,
                  opacity: layoutData.selections.contains(item) ? 1 : 0,
                  child: Container(
                    margin: padding,
                    color: Colors.black38,
                    child: LayoutBuilder(
                      builder: (context, constraint) => Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: min(constraint.maxHeight, constraint.maxWidth) *
                            0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }
}
