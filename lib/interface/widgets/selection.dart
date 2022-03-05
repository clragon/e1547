import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef SelectionChanged<T> = void Function(Set<T> selections);

class SelectionLayoutData<T> extends InheritedWidget {
  final Set<T> selections;
  final SelectionChanged<T> onChanged;
  final void Function()? onSelectAll;

  SelectionLayoutData({
    required Widget child,
    required this.selections,
    required this.onChanged,
    required this.onSelectAll,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant SelectionLayoutData oldWidget) =>
      (oldWidget.selections != selections || oldWidget.onChanged != onChanged);
}

class SelectionLayout<T> extends StatefulWidget {
  final Widget child;
  final Set<T>? selections;
  final Set<T> Function()? onSelectAll;
  final bool enabled;

  const SelectionLayout({
    required this.child,
    this.selections,
    this.onSelectAll,
    this.enabled = true,
  });

  static SelectionLayoutData<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>();
  }

  @override
  _SelectionLayoutState<T> createState() => _SelectionLayoutState<T>();
}

class _SelectionLayoutState<T> extends State<SelectionLayout<T>> {
  late Set<T> selections = widget.selections ?? {};

  @override
  void didUpdateWidget(covariant SelectionLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selections != widget.selections) {
      onSelectionChanged(widget.selections ?? {});
    }
  }

  void onSelectionChanged(Set<T> selections) {
    setState(() {
      this.selections = Set.from(selections);
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
        selections: selections,
        onChanged: onSelectionChanged,
        onSelectAll: widget.onSelectAll != null
            ? () => onSelectionChanged(widget.onSelectAll!())
            : null,
        child: widget.child,
      ),
    );
  }
}

class SelectionAppBar<T> extends StatelessWidget with PreferredSizeWidget {
  final List<Widget> Function(
      BuildContext context, SelectionLayoutData<T> layoutData) actionBuilder;
  final Widget Function(
      BuildContext context, SelectionLayoutData<T> layoutData)? titleBuilder;
  final PreferredSizeWidget appbar;

  @override
  Size get preferredSize => appbar.preferredSize;

  const SelectionAppBar({
    required this.appbar,
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
          icon: Icon(Icons.clear),
          onPressed: () => layoutData!.onChanged({}),
        ),
        actions: [
          if (layoutData!.onSelectAll != null)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: layoutData.onSelectAll,
            ),
          ...actionBuilder(context, layoutData),
        ],
      ),
      secondChild: appbar,
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
