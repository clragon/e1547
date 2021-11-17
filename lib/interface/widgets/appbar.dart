import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
  final bool automaticallyImplyLeading;

  const DefaultAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingAppBarFrame(
      elevation: elevation,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: AppBar(
          leading: leading,
          actions: actions,
          title: title,
          elevation: elevation,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      ),
    );
  }
}

class FloatingAppBarFrame extends StatelessWidget {
  final Widget child;
  final double? elevation;

  const FloatingAppBarFrame({
    required this.child,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kContentPadding).add(
        EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      ),
      child: Card(
        margin: EdgeInsets.all(kContentPadding),
        color: Theme.of(context).appBarTheme.backgroundColor,
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
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);
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
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: transparent ? Colors.transparent : null,
            ),
      ),
      child: DefaultAppBar(
        leading: leading,
        elevation: 0,
        title: title,
        actions: actions,
      ),
    );
  }
}

class DefaultSliverAppBar extends StatelessWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool floating;
  final bool pinned;
  final bool snap;

  const DefaultSliverAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.expandedHeight,
    this.flexibleSpace,
    this.floating = false,
    this.pinned = false,
    this.snap = false,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverStack(
      children: [
        SliverPositioned.fill(
          child: SliverPinnedHeader(
            child: Container(
              height: defaultAppBarHeight,
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
          ),
        ),
        MultiSliver(
          children: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: kContentPadding,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: kContentPadding * 2,
              ),
              sliver: SliverAppBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                collapsedHeight: kToolbarHeight,
                expandedHeight: expandedHeight,
                leading: leading,
                automaticallyImplyLeading: automaticallyImplyLeading,
                floating: floating,
                pinned: true,
                snap: snap,
                actions: actions,
                flexibleSpace: flexibleSpace,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: kContentPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
