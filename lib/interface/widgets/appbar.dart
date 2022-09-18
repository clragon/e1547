import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

abstract class AppBarBuilderWidget implements PreferredSizeWidget {
  abstract final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;
}

class AppBarBuilder extends StatelessWidget with AppBarBuilderWidget {
  const AppBarBuilder({required this.child, required this.builder});

  @override
  final PreferredSizeWidget child;
  final Widget Function(BuildContext context, PreferredSizeWidget child)
      builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class AppBarPadding extends StatelessWidget with AppBarBuilderWidget {
  const AppBarPadding({required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => Size(
        child.preferredSize.width + defaultAppBarHorizontalPadding,
        child.preferredSize.height + defaultAppBarTopPadding,
      );

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

AppBarLeadingConfiguration getLeadingConfiguration({
  required BuildContext context,
  required double width,
  double? alwaysShowDrawerBreakpoint = 800,
  Widget? leading,
  bool automaticallyImplyLeading = true,
}) {
  bool alwaysShowDrawer =
      alwaysShowDrawerBreakpoint != null && width >= alwaysShowDrawerBreakpoint;

  Widget? effectiveLeading = leading;
  double? leadingWidth;
  if (leading == null && automaticallyImplyLeading) {
    bool hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
    ModalRoute? parentRoute = ModalRoute.of(context);
    bool isFirst = parentRoute?.isFirst ?? false;
    bool canPop = parentRoute?.canPop ?? false;

    Widget drawerButton() => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: Scaffold.of(context).openDrawer,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );

    Widget backButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog
            ? const CloseButton()
            : const BackButton();

    if (hasDrawer && isFirst) {
      effectiveLeading = drawerButton();
    } else if (canPop) {
      if (alwaysShowDrawer && hasDrawer) {
        leadingWidth = 88;
        effectiveLeading = Row(
          children: [
            const SizedBox(width: 8),
            drawerButton(),
            backButton,
          ],
        );
      } else {
        effectiveLeading = backButton;
      }
    }
  }
  return AppBarLeadingConfiguration(
    leading: effectiveLeading,
    leadingWidth: leadingWidth,
  );
}

class DefaultAppBar extends StatelessWidget with PreferredSizeWidget {
  /// A preconfigured appbar.
  ///
  /// Contains extra behaviour such as:
  /// - double tap to scroll to the top of the primary scroll controller
  /// -  showing drawer and back button at the same time on wide screens
  const DefaultAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  /// Copied from [AppBar.title].
  final Widget? title;

  /// Copied from [AppBar.leading].
  final Widget? leading;

  /// Copied from [AppBar.actions].
  final List<Widget>? actions;

  /// Copied from [AppBar.elevation].
  final double? elevation;

  /// Copied from [AppBar.automaticallyImplyLeading].
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(defaultAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        AppBarLeadingConfiguration leadingConfig = getLeadingConfiguration(
          context: context,
          width: constraints.maxWidth,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: leading,
        );
        List<Widget>? effectiveActions = actions;
        if (actions != null) {
          effectiveActions = [...actions!, const SizedBox(width: 8)];
        }

        return AppBarPadding(
          child: AppBar(
            leading: leadingConfig.leading,
            leadingWidth: leadingConfig.leadingWidth,
            actions: effectiveActions,
            title: IgnorePointer(child: title),
            elevation: elevation,
            automaticallyImplyLeading: false,
            flexibleSpace: const ScrollToTop(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        );
      },
    );
  }
}

class AppBarLeadingConfiguration {
  /// Holds the configuration for a leading widget in an AppBar.
  const AppBarLeadingConfiguration({
    this.leading,
    this.leadingWidth,
  });

  /// The leading widget.
  final Widget? leading;

  /// The width of the leading widget.
  final double? leadingWidth;
}

class ScrollToTop extends StatelessWidget {
  const ScrollToTop({
    this.builder,
    this.child,
    this.controller,
    this.height,
    this.primary = true,
  });

  final Widget Function(BuildContext context, Widget child)? builder;
  final Widget? child;
  final ScrollController? controller;
  final double? height;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    Widget tapWrapper(Widget? child) {
      ScrollController? controller = this.controller ??
          (primary ? PrimaryScrollController.of(context) : null);
      return GestureDetector(
        onDoubleTap: controller != null
            ? () => controller.animateTo(
                  0,
                  duration: defaultAnimationDuration,
                  curve: Curves.easeOut,
                )
            : null,
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
  const TransparentAppBar({
    this.transparent = true,
    required this.child,
  });

  final bool transparent;

  @override
  final PreferredSizeWidget child;

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
  const SliverAppBarPadding({required this.child});

  final Widget child;

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
  const DefaultSliverAppBar({
    this.leading,
    this.actions,
    this.title,
    this.elevation,
    this.flexibleSpace,
    this.expandedHeight,
    this.bottom,
    this.floating = false,
    this.pinned = false,
    this.snap = false,
    this.automaticallyImplyLeading = true,
    this.forceElevated = false,
    this.scrollController,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final double? elevation;
  final bool forceElevated;
  final bool automaticallyImplyLeading;
  final double? expandedHeight;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final bool floating;
  final bool pinned;
  final bool snap;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBarPadding(
      child: SliverLayoutBuilder(
        builder: (context, constraints) {
          AppBarLeadingConfiguration leadingConfig = getLeadingConfiguration(
            context: context,
            width: constraints.crossAxisExtent,
            automaticallyImplyLeading: automaticallyImplyLeading,
            leading: leading,
          );
          return SliverAppBar(
            title: IgnorePointer(child: title),
            automaticallyImplyLeading: false,
            elevation: elevation,
            forceElevated: forceElevated,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            expandedHeight: expandedHeight,
            leading: leadingConfig.leading,
            leadingWidth: leadingConfig.leadingWidth,
            floating: floating,
            pinned: pinned,
            snap: snap,
            actions: actions,
            bottom: bottom,
            flexibleSpace: ScrollToTop(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottom?.preferredSize.height ?? 0,
                ),
                child: flexibleSpace,
              ),
            ),
          );
        },
      ),
    );
  }
}
