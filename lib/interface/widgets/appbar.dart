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
      child: AppBar(
        leading: leading,
        actions: actions,
        title: title,
        elevation: elevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
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
          children: [
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

mixin AppBarSize on Widget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);
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
        appBarTheme: AppBarTheme(
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
  final bool forceElevated;
  final bool automaticallyImplyLeading;
  final double? expandedHeight;
  final PreferredSizeWidget? bottom;
  final Widget Function(BuildContext context, bool collapsed)?
      flexibleSpaceBuilder;
  final bool floating;
  final bool pinned;
  final bool snap;

  const DefaultSliverAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.flexibleSpaceBuilder,
    this.expandedHeight,
    this.bottom,
    this.floating = false,
    this.pinned = false,
    this.snap = false,
    this.automaticallyImplyLeading = false,
    this.forceElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    double bottomHeight = bottom?.preferredSize.height ?? 0;

    return SliverStack(
      children: [
        SliverAppBar(
          elevation: 0,
          toolbarHeight: defaultAppBarHeight,
          expandedHeight: expandedHeight != null
              ? expandedHeight! + kContentPadding * 2
              : null,
          bottom: bottom != null
              ? PreferredSize(
                  preferredSize: bottom!.preferredSize,
                  child: Container(),
                )
              : null,
          automaticallyImplyLeading: false,
          floating: floating,
          pinned: pinned,
          snap: snap,
        ),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: MultiSliver(
            children: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: kContentPadding + MediaQuery.of(context).padding.top,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: kContentPadding * 2,
                ),
                sliver: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SliverAppBar(
                    title: title,
                    automaticallyImplyLeading: automaticallyImplyLeading,
                    elevation: elevation,
                    forceElevated: forceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    toolbarHeight: kToolbarHeight,
                    expandedHeight: expandedHeight,
                    leading: leading,
                    floating: floating,
                    pinned: pinned,
                    snap: snap,
                    actions: actions,
                    flexibleSpace: flexibleSpaceBuilder != null
                        ? LayoutBuilder(
                            builder: (context, constraints) => Padding(
                              padding: EdgeInsets.only(bottom: bottomHeight),
                              child: flexibleSpaceBuilder!(
                                context,
                                constraints.maxHeight ==
                                    kToolbarHeight + bottomHeight,
                              ),
                            ),
                          )
                        : null,
                    bottom: bottom,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: kContentPadding,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
