import 'package:flutter/material.dart';

class ScrollingAppbar extends StatelessWidget with PreferredSizeWidget {
  final ScrollController controller;
  final Widget child;

  const ScrollingAppbar({@required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: Theme.of(context).appBarTheme.elevation ?? 4,
      child: GestureDetector(
        onDoubleTap: controller != null
            ? () => controller.animateTo(controller.position.minScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn)
            : null,
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
