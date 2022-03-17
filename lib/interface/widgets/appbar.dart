import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

const double kContentPadding = 4;
const double defaultAppBarHeight = kToolbarHeight + (kContentPadding);
const EdgeInsets defaultListPadding = EdgeInsets.symmetric(
  horizontal: kContentPadding,
  vertical: kContentPadding * 2,
);
const double defaultActionListBottomHeight = kBottomNavigationBarHeight + 24;
final EdgeInsets defaultActionListPadding =
    defaultListPadding.copyWith(bottom: defaultActionListBottomHeight);

mixin AppBarSize on Widget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);
}

class DefaultAppBar extends StatelessWidget with AppBarSize {
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final ScrollController? scrollController;

  const DefaultAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kContentPadding * 2).add(
        EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kContentPadding,
        ),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ScrollToTopScope(
          height: kToolbarHeight,
          controller: scrollController,
          builder: (context, child) => AppBar(
            leading: leading,
            actions: actions,
            title: IgnorePointer(child: title),
            elevation: elevation,
            automaticallyImplyLeading: automaticallyImplyLeading,
            flexibleSpace: child,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }
}

class ScrollToTopScope extends StatelessWidget {
  final ScrollController? controller;
  final bool primary;
  final Widget Function(BuildContext context, Widget child)? builder;
  final Widget? child;
  final double? height;

  const ScrollToTopScope({
    this.builder,
    this.child,
    this.controller,
    this.height,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget tapWrapper(Widget? child) {
      ScrollController? controller = this.controller ??
          (primary ? PrimaryScrollController.of(context) : null);
      return GestureDetector(
        child: Container(
          height: height,
          color: Colors.transparent,
          child: child != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: child),
                        ],
                      ),
                    )
                  ],
                )
              : null,
        ),
        onDoubleTap: controller != null
            ? () => controller.animateTo(
                  0,
                  duration: defaultAnimationDuration,
                  curve: Curves.easeOut,
                )
            : null,
      );
    }

    Widget Function(BuildContext context, Widget child) builder =
        this.builder ?? (context, child) => child;

    return builder(
      context,
      tapWrapper(child),
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
      data: transparent
          ? Theme.of(context).copyWith(
              iconTheme: IconThemeData(color: Colors.white),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            )
          : Theme.of(context),
      child: DefaultAppBar(
        leading: leading,
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
  final Widget Function(BuildContext context, double collapse)?
      flexibleSpaceBuilder;
  final bool floating;
  final bool pinned;
  final bool snap;
  final ScrollController? scrollController;

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
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
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
              title: IgnorePointer(child: title),
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
              bottom: bottom,
              flexibleSpace: flexibleSpaceBuilder != null
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        double bottomHeight = bottom?.preferredSize.height ?? 0;
                        double minHeight = (kToolbarHeight + bottomHeight);
                        double maxHeight =
                            (expandedHeight ?? kToolbarHeight) - minHeight;
                        double currentHeight =
                            constraints.maxHeight - minHeight;
                        return ScrollToTopScope(
                          controller: scrollController,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: bottomHeight),
                            child: flexibleSpaceBuilder!(
                              context,
                              currentHeight / maxHeight,
                            ),
                          ),
                        );
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
