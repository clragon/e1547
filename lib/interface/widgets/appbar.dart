import 'package:flutter/material.dart';

const double kContentPadding = 4;

double defaultAppBarHeight = kToolbarHeight + (kContentPadding * 2);

EdgeInsets defaultListPadding = EdgeInsets.all(kContentPadding);

EdgeInsets defaultActionListPadding = defaultListPadding.copyWith(
  bottom: kBottomNavigationBarHeight + 24,
);

class DefaultAppBar extends StatelessWidget with AppBarSize {
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final double? elevation;
  final Color? backgroundColor;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight ?? defaultAppBarHeight);

  const DefaultAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.backgroundColor,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingAppBarFrame(
      backgroundColor: backgroundColor,
      elevation: elevation,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: AppBar(
          leading: leading,
          actions: actions,
          title: title,
          elevation: elevation,
          backgroundColor: backgroundColor,
          toolbarHeight: toolbarHeight,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      ),
    );
  }
}

class FloatingAppBarFrame extends StatelessWidget {
  final Widget child;
  final double? elevation;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const FloatingAppBarFrame({
    required this.child,
    this.elevation,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: kContentPadding).add(
            EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
      child: Card(
        margin: EdgeInsets.all(kContentPadding),
        color: backgroundColor ?? Theme.of(context).canvasColor,
        clipBehavior: Clip.antiAlias,
        elevation: elevation ?? 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [child],
        ),
      ),
    );
  }
}

mixin AppBarSize on Widget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ScrollToTop extends StatelessWidget with AppBarSize {
  final ScrollController? controller;
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

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

class TransparentAppBar extends StatelessWidget {
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
        iconTheme: transparent ? IconThemeData(color: Colors.white) : null,
      ),
      child: DefaultAppBar(
        leading: leading,
        elevation: 0,
        backgroundColor: transparent ? Colors.transparent : null,
        title: title,
        actions: actions,
      ),
    );
  }
}
