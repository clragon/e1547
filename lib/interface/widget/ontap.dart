import 'package:flutter/material.dart';

class MouseCursorRegion extends StatelessWidget {
  const MouseCursorRegion({
    super.key,
    this.child,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.behavior,
  });

  /// The child of this area.
  final Widget? child;

  /// Called when a tap with a primary button has occurred.
  final VoidCallback? onTap;

  /// Called when a long press gesture with a primary button has occured.
  final VoidCallback? onLongPress;

  /// Called when a tap with a secondary button has occurred.
  final VoidCallback? onSecondaryTap;

  /// How this gesture detector should behave during hit testing.
  final HitTestBehavior? behavior;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:
        [onTap, onLongPress, onSecondaryTap].any((e) => e != null)
            ? SystemMouseCursors.click
            : MouseCursor.defer,
    hitTestBehavior: HitTestBehavior.deferToChild,
    child: GestureDetector(
      behavior: behavior,
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: child,
    ),
  );
}
