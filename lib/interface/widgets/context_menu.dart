import 'package:flutter/material.dart';

/// Displays a context menu at [offset].
///
/// [initialIndex] can be specified to have an initially selected item.
void showContextMenu({
  required BuildContext context,
  required Offset offset,
  int? initialIndex,
  required List<ContextMenuItem> items,
}) {
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      offset,
      offset,
    ),
    Offset.zero & overlay.size,
  );
  if (items.isNotEmpty) {
    showMenu(
      context: context,
      position: position,
      initialValue: initialIndex,
      items: items
          .map(
            (e) => PopupMenuItem<int>(
              value: items.indexOf(e),
              onTap: e.onTap,
              child: e.child,
            ),
          )
          .toList(),
    );
  }
}

class ContextMenuArea extends StatelessWidget {
  /// Creates a right click context menu for its [child].
  const ContextMenuArea({
    super.key,
    required this.child,
    required this.items,
    this.initialIndex,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The items of this menu.
  final List<ContextMenuItem> items;

  /// The initially highlighted item.
  final int? initialIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) => showContextMenu(
        context: context,
        offset: details.globalPosition,
        initialIndex: initialIndex,
        items: items,
      ),
      onLongPressStart: (details) => showContextMenu(
        context: context,
        offset: details.globalPosition,
        initialIndex: initialIndex,
        items: items,
      ),
      child: child,
    );
  }
}

class ContextMenuItem {
  /// An item displayed in a context menu.
  ContextMenuItem({
    required this.child,
    this.onTap,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when the menu item is tapped.
  final VoidCallback? onTap;
}
