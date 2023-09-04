import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class SelectionLayoutData<T> extends InheritedWidget {
  /// Provides selection actions for a [SelectionLayout] to its subtree.
  const SelectionLayoutData({
    super.key,
    required super.child,
    required this.selections,
    required this.onChanged,
    required this.items,
  });

  /// All selected items.
  final Set<T> selections;

  /// All items that can be selected.
  final List<T> items;

  /// Called when the selection is changed.
  final ValueChanged<Set<T>> onChanged;

  /// Ensures that an item is part of this [SelectionLayout].
  void _assertItemOwnership(T item) {
    if (!items.contains(item)) {
      throw StateError('Cannot select an item which is not part of items!');
    }
  }

  /// Clears the selection.
  void clear() => onChanged(const {});

  /// Selects all items.
  void selectAll() => onChanged(items.toSet());

  /// Returns whether an item is currently selected.
  bool isSelected(T item) {
    _assertItemOwnership(item);
    return selections.contains(item);
  }

  /// Selects an item.
  /// Does nothing if the item is already selected.
  void select(T item) {
    _assertItemOwnership(item);
    if (!isSelected(item)) {
      onChanged(Set.of(selections)..add(item));
    }
  }

  /// Deselects an item.
  /// Does nothing if the item is not selected.
  void deselect(T item) {
    _assertItemOwnership(item);
    if (isSelected(item)) {
      onChanged(Set.of(selections)..remove(item));
    }
  }

  /// Sets the selection of an item.
  /// Does nothing if already in correct state.
  void setSelection(T item, bool selected) {
    if (selected) {
      select(item);
    } else {
      deselect(item);
    }
  }

  /// Toggles the selection state of an item.
  void toggleSelection(T item) => setSelection(
        item,
        !isSelected(item),
      );

  @override
  bool updateShouldNotify(covariant SelectionLayoutData<T> oldWidget) =>
      (oldWidget.selections != selections || oldWidget.onChanged != onChanged);
}

class SelectionLayout<T> extends StatefulWidget {
  /// Provides item selection for a subtree.
  const SelectionLayout({
    super.key,
    required this.child,
    required this.items,
    this.enabled = true,
  });

  /// The widget below this one on the tree.
  final Widget child;

  /// All items which can be selected.
  final List<T>? items;

  /// Whether items can currently be selected.
  final bool enabled;

  /// Returns the [SelectionLayoutData] of the current context.
  /// Throws an error if there is none.
  static SelectionLayoutData<T> of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>()!;

  /// Returns the [SelectionLayoutData] of the current context or null, if there is none.
  static SelectionLayoutData<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionLayoutData<T>>();

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
  /// Provides an appbar for handling the selection of items.
  /// Replaces the normal appbar as soon as a selection starts.
  const SelectionAppBar({
    super.key,
    required this.child,
    required this.actionBuilder,
    this.titleBuilder,
  });

  /// The list of actions for the selection appbar.
  /// Automatically contains an action to select all items.
  final List<Widget> Function(
      BuildContext context, SelectionLayoutData<T> layoutData) actionBuilder;

  /// Called to display the title for the selection appbar.
  /// Defaults to '<count> items'.
  final Widget Function(
      BuildContext context, SelectionLayoutData<T> layoutData)? titleBuilder;

  /// The appbar that is shown when no selection is taking place.
  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.maybeOf<T>(context);
    return CrossFade.builder(
      showChild: layoutData != null && layoutData.selections.isNotEmpty,
      builder: (context) => DefaultAppBar(
        title: titleBuilder?.call(context, layoutData!) ??
            Text('${layoutData!.selections.length} items'),
        leading: IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Abort',
          onPressed: layoutData!.clear,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'Select all',
            onPressed: layoutData.selectAll,
          ),
          ...actionBuilder(context, layoutData),
        ],
      ),
      secondChild: child,
    );
  }
}

class SelectionItemOverlay<T> extends StatelessWidget {
  /// Alows long press actions to start selecting items.
  const SelectionItemOverlay({
    super.key,
    required this.child,
    required this.item,
    this.padding,
  });

  /// The widget below this one in the tree.
  final Widget child;

  /// The item that can be selected.
  final T item;

  /// Padding of this widget.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    SelectionLayoutData<T>? layoutData = SelectionLayout.maybeOf<T>(context);
    if (layoutData != null) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: MouseCursorRegion(
              behavior: HitTestBehavior.translucent,
              onTap: layoutData.selections.isNotEmpty
                  ? () => layoutData.toggleSelection(item)
                  : null,
              onLongPress: () => layoutData.toggleSelection(item),
              onSecondaryTap: () => layoutData.toggleSelection(item),
              child: ExcludeFocus(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: defaultAnimationDuration,
                    opacity: layoutData.selections.contains(item) ? 1 : 0,
                    child: Container(
                      margin: padding,
                      color: Colors.black38,
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 60,
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
