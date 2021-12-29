import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

const double kContentPadding = 4;

double defaultAppBarHeight = kToolbarHeight + (kContentPadding * 2);

EdgeInsets defaultListPadding = EdgeInsets.all(kContentPadding);

double defaultActionListBottomHeight = kBottomNavigationBarHeight + 24;

EdgeInsets defaultActionListPadding =
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
    return FloatingAppBarFrame(
      elevation: elevation,
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
          actions: [
            SizedBox.shrink(),
          ],
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
                    flexibleSpace: flexibleSpaceBuilder != null
                        ? LayoutBuilder(
                            builder: (context, constraints) => Padding(
                              padding: EdgeInsets.only(bottom: bottomHeight),
                              child: ScrollToTopScope(
                                controller: scrollController,
                                child: flexibleSpaceBuilder!(
                                  context,
                                  constraints.maxHeight ==
                                      kToolbarHeight + bottomHeight,
                                ),
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

class SelectionScope<T> extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    Set<T> selections,
    void Function(Set<T> selections) onChanged,
  ) builder;
  final Set<T>? selections;

  const SelectionScope({required this.builder, this.selections});

  @override
  _SelectionScopeState<T> createState() => _SelectionScopeState<T>();
}

class _SelectionScopeState<T> extends State<SelectionScope<T>> {
  late Set<T> selections = widget.selections ?? {};

  @override
  void didUpdateWidget(covariant SelectionScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selections != widget.selections) {
      onChanged(widget.selections ?? {});
    }
  }

  void onChanged(Set<T> selections) => setState(() {
        this.selections.clear();
        this.selections.addAll(selections);
      });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: widget.builder(
        context,
        selections,
        onChanged,
      ),
      onWillPop: () async {
        if (selections.isNotEmpty) {
          onChanged({});
          return false;
        } else {
          return true;
        }
      },
    );
  }
}

class SelectionAppBar<T> extends StatelessWidget {
  final Set<T> Function()? onSelectAll;
  final void Function(Set<T> selections) onChanged;
  final Set<T> selections;
  final List<Widget> actions;

  final WidgetBuilder? titleBuilder;

  const SelectionAppBar({
    required this.selections,
    required this.onChanged,
    required this.actions,
    this.titleBuilder,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      title: titleBuilder?.call(context) ?? Text('${selections.length} items'),
      leading: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => onChanged({}),
      ),
      actions: [
        if (onSelectAll != null)
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              onChanged(onSelectAll!());
            },
          ),
        ...actions,
      ],
    );
  }
}

class SelectionItemOverlay<T> extends StatelessWidget {
  final Widget child;
  final T item;
  final Set<T> selections;
  final void Function(Set<T> selections) onChanged;
  final bool enabled;
  final EdgeInsets? padding;

  const SelectionItemOverlay({
    required this.child,
    required this.item,
    required this.selections,
    required this.onChanged,
    this.enabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    void select() {
      Set<T> updated = Set.from(selections);
      if (updated.contains(item)) {
        updated.remove(item);
      } else {
        updated.add(item);
      }
      onChanged(updated);
    }

    if (enabled) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: selections.isNotEmpty ? select : null,
              onLongPress: select,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: defaultAnimationDuration,
                  opacity: selections.contains(item) ? 1 : 0,
                  child: Container(
                    margin: padding,
                    color: Colors.black38,
                    child: LayoutBuilder(
                      builder: (context, constraint) => Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: min(constraint.maxHeight, constraint.maxWidth) *
                            0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }
}
