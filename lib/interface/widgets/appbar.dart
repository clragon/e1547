import 'package:flutter/material.dart';

mixin AppBarSize on Widget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ScrollToTop extends StatelessWidget with AppBarSize {
  final ScrollController? controller;
  final Widget child;

  const ScrollToTop({required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: controller != null
          ? () => controller!.animateTo(
                controller!.position.minScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              )
          : null,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

class TransparentAppBar extends StatelessWidget with AppBarSize {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool transparent;

  const TransparentAppBar({
    this.actions,
    this.title,
    this.leading,
    this.transparent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: Colors.white),
      ),
      child: AppBar(
        leading: leading,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: title,
        actions: actions,
      ),
    );
  }
}
