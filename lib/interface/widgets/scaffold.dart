import 'package:e1547/interface/interface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    this.config,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.navigationRail,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  /// Configuration for the apdative behavior.
  final AdaptiveScaffoldConfig? config;

  /// Copied from [Scaffold.appBar]
  final PreferredSizeWidget? appBar;

  /// Copied from [Scaffold.body]
  final Widget? body;

  /// Copied from [Scaffold.floatingActionButton]
  final Widget? floatingActionButton;

  /// Copied from [Scaffold.floatingActionButtonLocation]
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Copied from [Scaffold.floatingActionButtonAnimator]
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// Copied from [Scaffold.persistentFooterButtons]
  final List<Widget>? persistentFooterButtons;

  /// Copied from [Scaffold.drawer]
  final Widget? drawer;

  /// Copied from [Scaffold.onDrawerChanged]
  final DrawerCallback? onDrawerChanged;

  /// Copied from [Scaffold.endDrawer]
  final Widget? endDrawer;

  /// Copied from [Scaffold.onEndDrawerChanged]
  final DrawerCallback? onEndDrawerChanged;

  /// A [NavigationRail] that is shown instead of the [drawer] when the desired breakpoint is met.
  /// The rail is shown on the left side and is replaced by the [drawer].
  final Widget? navigationRail;

  /// Copied from [Scaffold.bottomNavigationBar]
  final Widget? bottomNavigationBar;

  /// Copied from [Scaffold.bottomSheet]
  final Widget? bottomSheet;

  /// Copied from [Scaffold.backgroundColor]
  final Color? backgroundColor;

  /// Copied from [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// Copied from [Scaffold.primary]
  final bool primary;

  /// Copied from [Scaffold.drawerDragStartBehavior]
  final DragStartBehavior drawerDragStartBehavior;

  /// Copied from [Scaffold.extendBody]
  final bool extendBody;

  /// Copied from [Scaffold.extendBodyBehindAppBar]
  final bool extendBodyBehindAppBar;

  /// Copied from [Scaffold.drawerScrimColor]
  final Color? drawerScrimColor;

  /// Copied from [Scaffold.drawerEdgeDragWidth]
  final double? drawerEdgeDragWidth;

  /// Copied from [Scaffold.drawerEnableOpenDragGesture]
  final bool drawerEnableOpenDragGesture;

  /// Copied from [Scaffold.endDrawerEnableOpenDragGesture]
  final bool endDrawerEnableOpenDragGesture;

  /// Copied from [Scaffold.restorationId]
  final String? restorationId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => _AdaptiveScaffoldBody(
          constraints: constraints,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          floatingActionButtonAnimator: floatingActionButtonAnimator,
          persistentFooterButtons: persistentFooterButtons,
          drawer: drawer,
          onDrawerChanged: onDrawerChanged,
          endDrawer: endDrawer,
          onEndDrawerChanged: onEndDrawerChanged,
          bottomNavigationBar: bottomNavigationBar,
          bottomSheet: bottomSheet,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          primary: primary,
          drawerDragStartBehavior: drawerDragStartBehavior,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          drawerScrimColor: drawerScrimColor,
          drawerEdgeDragWidth: drawerEdgeDragWidth,
          drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
          endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
          restorationId: restorationId,
        ),
      );
}

class _AdaptiveScaffoldBody extends Scaffold {
  factory _AdaptiveScaffoldBody({
    Key? key,
    required BoxConstraints constraints,
    AdaptiveScaffoldConfig? config,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    Widget? drawer,
    DrawerCallback? onDrawerChanged,
    Widget? endDrawer,
    DrawerCallback? onEndDrawerChanged,
    Widget? navigationRail,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    Color? backgroundColor,
    bool? resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    Color? drawerScrimColor,
    double? drawerEdgeDragWidth,
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true,
    String? restorationId,
  }) {
    AdaptiveScaffoldConfig effectiveConfig = AdaptiveScaffoldConfig(
      drawerBreakpoint:
          config?.drawerBreakpoint ?? _defaultConfig.drawerBreakpoint,
      endDrawerBreakpoint:
          config?.endDrawerBreakpoint ?? _defaultConfig.endDrawerBreakpoint,
      navigationRailBreakpoint: config?.navigationRailBreakpoint ??
          _defaultConfig.navigationRailBreakpoint,
      adaptDrawer: config?.adaptDrawer ?? _defaultConfig.adaptDrawer,
      adaptEndDrawer: config?.adaptEndDrawer ?? _defaultConfig.adaptEndDrawer,
    );

    Widget? effectiveDrawer = drawer;
    Widget? inlineDrawer;
    if (drawer != null &&
        effectiveConfig.adaptDrawer &&
        effectiveConfig.drawerBreakpoint! <= constraints.maxWidth) {
      effectiveDrawer = null;
      inlineDrawer = drawer;
    }

    Widget? effectiveEndDrawer = endDrawer;
    Widget? inlineEndDrawer;
    if (endDrawer != null &&
        effectiveConfig.adaptEndDrawer &&
        effectiveConfig.endDrawerBreakpoint! <= constraints.maxWidth) {
      effectiveEndDrawer = null;
      inlineEndDrawer = endDrawer;
    }

    List<Widget> bodyChildren = [
      CrossFade.builder(
          showChild: inlineDrawer != null, builder: (context) => inlineDrawer!),
      if (body != null) Expanded(child: body),
      CrossFade.builder(
          showChild: inlineEndDrawer != null,
          builder: (context) => inlineEndDrawer!),
    ];

    Widget? effectiveBody;
    if (bodyChildren.isNotEmpty) {
      effectiveBody = Row(
        children: bodyChildren,
      );
    }

    PreferredSizeWidget? effectiveAppBar;
    if (appBar != null) {
      effectiveAppBar = AppBarBuilder(
        child: appBar,
        builder: (context, child) => KeyedSubtree(
          key: ObjectKey(Object.hash(inlineDrawer, inlineEndDrawer, body)),
          child: child,
        ),
      );
    }

    return _AdaptiveScaffoldBody._(
      key: key,
      appBar: effectiveAppBar,
      body: effectiveBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: effectiveDrawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: effectiveEndDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }

  /// Displays Scaffold drawer and end drawer next to the body if breakpoints are met.
  const _AdaptiveScaffoldBody._({
    super.key,
    super.appBar,
    super.body,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.floatingActionButtonAnimator,
    super.persistentFooterButtons,
    super.drawer,
    super.onDrawerChanged,
    super.endDrawer,
    super.onEndDrawerChanged,
    super.bottomNavigationBar,
    super.bottomSheet,
    super.backgroundColor,
    super.resizeToAvoidBottomInset,
    super.primary,
    super.drawerDragStartBehavior,
    super.extendBody,
    super.extendBodyBehindAppBar,
    super.drawerScrimColor,
    super.drawerEdgeDragWidth,
    super.drawerEnableOpenDragGesture,
    super.endDrawerEnableOpenDragGesture,
    super.restorationId,
  });

  /// Default aaptive scaffold configuration.
  static const AdaptiveScaffoldConfig _defaultConfig = AdaptiveScaffoldConfig(
    navigationRailBreakpoint: 800,
    drawerBreakpoint: 1200,
    endDrawerBreakpoint: 1600,
  );

  @override
  ScaffoldState createState() => _AdaptiveScaffoldBodyState();
}

class _AdaptiveScaffoldBodyState extends ScaffoldState {}

class AdaptiveScaffoldConfig {
  /// Configures a [_AdaptiveScaffoldBody].
  const AdaptiveScaffoldConfig({
    this.drawerBreakpoint,
    this.endDrawerBreakpoint,
    this.navigationRailBreakpoint,
    this.adaptDrawer = true,
    this.adaptEndDrawer = true,
  });

  /// At which width the drawer should be shown permanently.
  final double? drawerBreakpoint;

  /// At which width the end drawer should be shown permanently.
  final double? endDrawerBreakpoint;

  /// At which width the navigation rail should be shown.
  final double? navigationRailBreakpoint;

  /// Whether the drawer should be shown permanently.
  final bool adaptDrawer;

  /// Whether the end drawer should be shown permanently.
  final bool adaptEndDrawer;
}
