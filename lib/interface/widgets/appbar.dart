import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

abstract class AppBarBuilderWidget implements PreferredSizeWidget {
  abstract final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;
}

class AppBarBuilder extends StatelessWidget with AppBarBuilderWidget {
  @override
  final PreferredSizeWidget child;
  final Widget Function(BuildContext context, PreferredSizeWidget child)
      builder;

  const AppBarBuilder({Key? key, required this.child, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class AppBarPadding extends StatelessWidget with AppBarBuilderWidget {
  @override
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => Size(
        child.preferredSize.width + defaultAppBarHorizontalPadding,
        child.preferredSize.height + defaultAppBarTopPadding,
      );

  const AppBarPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: defaultAppBarHorizontalPadding)
              .add(
        EdgeInsets.only(
          top: defaultAppBarTopPadding + MediaQuery.of(context).padding.top,
        ),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: child,
      ),
    );
  }
}

class DefaultAppBar extends StatelessWidget with PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final ScrollController? scrollController;

  @override
  Size get preferredSize => const Size.fromHeight(defaultAppBarHeight);

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
    return AppBarPadding(
      child: AppBar(
        leading: leading,
        actions: actions,
        title: IgnorePointer(child: title),
        elevation: elevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
        flexibleSpace: ScrollToTop(controller: scrollController),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }
}

class ScrollToTop extends StatelessWidget {
  final ScrollController? controller;
  final bool primary;
  final Widget Function(BuildContext context, Widget child)? builder;
  final Widget? child;
  final double? height;

  const ScrollToTop({
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

class TransparentAppBar extends StatelessWidget with AppBarBuilderWidget {
  final bool transparent;

  @override
  final PreferredSizeWidget child;

  const TransparentAppBar({
    this.transparent = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              elevation: transparent ? 0 : null,
              backgroundColor: transparent ? Colors.transparent : null,
            ),
      ),
      child: child,
    );
  }
}

class SliverAppBarPadding extends StatelessWidget {
  final Widget child;

  const SliverAppBarPadding({Key? key, required this.child}) : super(key: key);

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
          padding: const EdgeInsets.symmetric(
            horizontal: kContentPadding * 2,
          ),
          sliver: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
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
  final Widget Function(BuildContext context, double extension)?
      flexibleSpaceBuilder;
  final Widget? flexibleSpace;
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
    this.flexibleSpace,
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
    return SliverAppBarPadding(
      child: SliverAppBar(
        title: IgnorePointer(child: title),
        automaticallyImplyLeading: automaticallyImplyLeading,
        elevation: elevation,
        forceElevated: forceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
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
                  double currentHeight = constraints.maxHeight - minHeight;
                  return ScrollToTop(
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
            : flexibleSpace,
      ),
    );
  }
}
