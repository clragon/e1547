import 'package:e1547/interface/interface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatefulWidget {
  /// Displays Scaffold drawer and end drawer next to the body if breakpoints are met.
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
    this.isDrawerOpen,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.isEndDrawerOpen,
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

  /// Defines whether the inline drawer is initially open or not.
  ///
  /// Defaults to the value of [AdaptiveScaffoldController] or to true.
  final bool? isDrawerOpen;

  /// Copied from [Scaffold.endDrawer]
  final Widget? endDrawer;

  /// Copied from [Scaffold.onEndDrawerChanged]
  final DrawerCallback? onEndDrawerChanged;

  /// Defines whether the inline end drawer is initially open or not.
  ///
  /// Defaults to the value of [AdaptiveScaffoldController] or to true.
  final bool? isEndDrawerOpen;

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
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  /// Default adaptive scaffold configuration.
  static const AdaptiveScaffoldConfig _defaultConfig = AdaptiveScaffoldConfig(
    navigationRailBreakpoint: 800,
    drawerBreakpoint: 1200,
    endDrawerBreakpoint: 1600,
  );

  late bool _isInlineDrawerOpen = widget.isDrawerOpen ??
      context.read<AdaptiveScaffoldController?>()?.isDrawerOpen ??
      true;

  /// Indicates whether the drawer is currently "open".
  /// This means, the drawer is shown besides the body,
  /// and is different from the drawer being shown as overlay.
  ///
  /// If an [AdaptiveScaffoldController] is available from context, it will be used to define the default value.
  bool get isInlineDrawerOpen => _isInlineDrawerOpen;
  set isInlineDrawerOpen(bool value) {
    AdaptiveScaffoldController? controller =
        context.read<AdaptiveScaffoldController?>();
    if (controller != null) {
      controller.isDrawerOpen = value;
    }
    _isInlineDrawerOpen = value;
  }

  late bool _isInlineEndDrawerOpen = widget.isEndDrawerOpen ??
      context.read<AdaptiveScaffoldController?>()?.isEndDrawerOpen ??
      true;

  /// Indicates whether the end drawer is currently "open".
  /// This means, the end drawer is shown besides the body,
  /// and is different from the end drawer being shown as overlay.
  ///
  /// If an [AdaptiveScaffoldController] is available from context, it will be used to define the default value.
  bool get isInlineEndDrawerOpen => _isInlineEndDrawerOpen;
  set isInlineEndDrawerOpen(bool value) {
    AdaptiveScaffoldController? controller =
        context.read<AdaptiveScaffoldController?>();
    if (controller != null) {
      controller.isEndDrawerOpen = value;
    }
    _isInlineEndDrawerOpen = value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        AdaptiveScaffoldConfig effectiveConfig = AdaptiveScaffoldConfig(
          drawerBreakpoint: widget.config?.drawerBreakpoint ??
              _defaultConfig.drawerBreakpoint,
          endDrawerBreakpoint: widget.config?.endDrawerBreakpoint ??
              _defaultConfig.endDrawerBreakpoint,
          navigationRailBreakpoint: widget.config?.navigationRailBreakpoint ??
              _defaultConfig.navigationRailBreakpoint,
          adaptDrawer: widget.config?.adaptDrawer ?? _defaultConfig.adaptDrawer,
          adaptEndDrawer:
              widget.config?.adaptEndDrawer ?? _defaultConfig.adaptEndDrawer,
        );

        Widget? effectiveDrawer = widget.drawer;
        Widget? inlineDrawer;
        if (widget.drawer != null &&
            effectiveConfig.adaptDrawer &&
            effectiveConfig.drawerBreakpoint! <= constraints.maxWidth) {
          effectiveDrawer = null;
          inlineDrawer = widget.drawer;
        }

        Widget? effectiveEndDrawer = widget.endDrawer;
        Widget? inlineEndDrawer;
        if (widget.endDrawer != null &&
            effectiveConfig.adaptEndDrawer &&
            effectiveConfig.endDrawerBreakpoint! <= constraints.maxWidth) {
          effectiveEndDrawer = null;
          inlineEndDrawer = widget.endDrawer;
        }

        _CustomDrawerAction? drawerAction;
        if (inlineDrawer != null && effectiveConfig.collapseDrawer) {
          drawerAction = _CustomDrawerAction(
            isDrawerOpen: isInlineDrawerOpen,
            onDrawerChanged: (value) =>
                setState(() => isInlineDrawerOpen = value),
          );
        }

        _CustomDrawerAction? endDrawerAction;
        if (inlineEndDrawer != null && effectiveConfig.collapseEndDrawer) {
          endDrawerAction = _CustomDrawerAction(
            isDrawerOpen: isInlineEndDrawerOpen,
            onDrawerChanged: (value) =>
                setState(() => isInlineEndDrawerOpen = value),
          );
        }

        bool showInlineDrawer = (drawerAction?.isDrawerOpen ?? true);
        bool showInlineEndDrawer = (endDrawerAction?.isDrawerOpen ?? true);

        if (!showInlineDrawer) {
          effectiveDrawer = inlineDrawer;
        }
        if (!showInlineEndDrawer) {
          effectiveEndDrawer = inlineEndDrawer;
        }

        List<Widget> bodyChildren = [
          CrossFade.builder(
            showChild: inlineDrawer != null && showInlineDrawer,
            builder: (context) => inlineDrawer!,
          ),
          if (widget.body != null) Expanded(child: widget.body!),
          CrossFade.builder(
            showChild: inlineEndDrawer != null && showInlineEndDrawer,
            builder: (context) => inlineEndDrawer!,
          ),
        ];

        Widget? effectiveBody;
        if (bodyChildren.isNotEmpty) {
          effectiveBody = Row(
            children: bodyChildren,
          );
        }

        PreferredSizeWidget? effectiveAppBar;
        if (widget.appBar != null) {
          effectiveAppBar = AppBarBuilder(
            child: widget.appBar!,
            builder: (context, child) => KeyedSubtree(
              key: ObjectKey(
                  Object.hash(inlineDrawer, inlineEndDrawer, widget.body)),
              child: child,
            ),
          );
        }

        return _AdaptiveScaffoldBody(
          appBar: effectiveAppBar,
          body: effectiveBody,
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
          persistentFooterButtons: widget.persistentFooterButtons,
          drawer: effectiveDrawer,
          drawerAction: drawerAction,
          onDrawerChanged: widget.onDrawerChanged,
          endDrawer: effectiveEndDrawer,
          endDrawerAction: endDrawerAction,
          onEndDrawerChanged: widget.onEndDrawerChanged,
          bottomNavigationBar: widget.bottomNavigationBar,
          bottomSheet: widget.bottomSheet,
          backgroundColor: widget.backgroundColor,
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          primary: widget.primary,
          drawerDragStartBehavior: widget.drawerDragStartBehavior,
          extendBody: widget.extendBody,
          extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
          drawerScrimColor: widget.drawerScrimColor,
          drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
          drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
          endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
          restorationId: widget.restorationId,
        );
      },
    );
  }
}

class _AdaptiveScaffoldBody extends Scaffold {
  const _AdaptiveScaffoldBody({
    super.appBar,
    super.body,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.floatingActionButtonAnimator,
    super.persistentFooterButtons,
    super.drawer,
    this.drawerAction,
    super.onDrawerChanged,
    super.endDrawer,
    this.endDrawerAction,
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

  /// Used to control the drawer from the outside.
  /// If non-null, [_AdaptiveScaffoldBodyState] will act as if there is a drawer available.
  final _CustomDrawerAction? drawerAction;

  /// Used to control the end drawer from the outside.
  /// If non-null, [_AdaptiveScaffoldBodyState] will act as if there is an end drawer available.
  final _CustomDrawerAction? endDrawerAction;

  @override
  ScaffoldState createState() => _AdaptiveScaffoldBodyState();
}

class _AdaptiveScaffoldBodyState extends ScaffoldState {
  /// Used to control the drawer from the outside.
  /// If non-null, [_AdaptiveScaffoldBodyState] will act as if there is a drawer available.
  _CustomDrawerAction? get drawerAction {
    if (widget is _AdaptiveScaffoldBody) {
      return (widget as _AdaptiveScaffoldBody).drawerAction;
    }
    return null;
  }

  /// Used to control the end drawer from the outside.
  /// If non-null, [_AdaptiveScaffoldBodyState] will act as if there is an end drawer available.
  _CustomDrawerAction? get endDrawerAction {
    if (widget is _AdaptiveScaffoldBody) {
      return (widget as _AdaptiveScaffoldBody).endDrawerAction;
    }
    return null;
  }

  @override
  bool get hasDrawer => drawerAction != null || super.hasDrawer;

  @override
  bool get isDrawerOpen => drawerAction?.isDrawerOpen ?? super.isDrawerOpen;

  @override
  void openDrawer({bool toggle = true}) {
    if (drawerAction != null) {
      if (toggle && isDrawerOpen) {
        closeDrawer(inline: true);
      } else {
        drawerAction!.onDrawerChanged(true);
      }
    } else {
      super.openDrawer();
    }
  }

  @override
  void closeDrawer({bool inline = false}) {
    if (drawerAction != null) {
      if (!inline) return;
      drawerAction!.onDrawerChanged(false);
    } else {
      super.closeDrawer();
    }
  }

  @override
  bool get hasEndDrawer => endDrawerAction != null || super.hasEndDrawer;

  @override
  bool get isEndDrawerOpen =>
      endDrawerAction?.isDrawerOpen ?? super.isEndDrawerOpen;

  @override
  void openEndDrawer({bool toggle = true}) {
    if (endDrawerAction != null) {
      if (toggle && isEndDrawerOpen) {
        closeEndDrawer(inline: true);
      } else {
        endDrawerAction!.onDrawerChanged(true);
      }
    } else {
      super.openEndDrawer();
    }
  }

  @override
  void closeEndDrawer({bool inline = false}) {
    if (endDrawerAction != null) {
      if (!inline) return;
      endDrawerAction!.onDrawerChanged(false);
    } else {
      super.closeEndDrawer();
    }
  }
}

class AdaptiveScaffoldConfig {
  /// Configures a [_AdaptiveScaffoldBody].
  const AdaptiveScaffoldConfig({
    this.drawerBreakpoint,
    this.endDrawerBreakpoint,
    this.navigationRailBreakpoint,
    this.adaptDrawer = true,
    this.adaptEndDrawer = true,
    this.collapseDrawer = true,
    this.collapseEndDrawer = true,
  });

  /// At which width the drawer should be shown permanently.
  final double? drawerBreakpoint;

  /// At which width the end drawer should be shown permanently.
  final double? endDrawerBreakpoint;

  /// At which width the navigation rail should be shown.
  final double? navigationRailBreakpoint;

  /// Whether the drawer should be shown permanently.
  final bool adaptDrawer;

  /// Whether the drawer can be collapsed.
  final bool collapseDrawer;

  /// Whether the end drawer can be collapsed.
  final bool collapseEndDrawer;

  /// Whether the end drawer should be shown permanently.
  final bool adaptEndDrawer;
}

class _CustomDrawerAction {
  // Used to override drawer behaviour without passing a drawer.
  const _CustomDrawerAction({
    required this.isDrawerOpen,
    required this.onDrawerChanged,
  });

  /// Indicates whether the drawer is currently open.
  final bool isDrawerOpen;

  /// Called to open or close the drawer.
  final DrawerCallback onDrawerChanged;
}

class AdaptiveScaffoldController extends ChangeNotifier {
  AdaptiveScaffoldController({
    bool isDrawerOpen = true,
    bool isEndDrawerOpen = true,
  })  : _isDrawerOpen = isDrawerOpen,
        _isEndDrawerOpen = isEndDrawerOpen;

  bool _isDrawerOpen;

  /// Indicates whether the drawers in the [AdaptiveScaffold]s below this scope are currently open or closed.
  bool get isDrawerOpen => _isDrawerOpen;

  /// Indicates whether the end drawers in the [AdaptiveScaffold]s below this scope are currently open or closed.
  set isDrawerOpen(bool value) {
    if (_isDrawerOpen != value) {
      _isDrawerOpen = value;
      notifyListeners();
    }
  }

  bool _isEndDrawerOpen;

  /// Indicates whether the end drawers in the [AdaptiveScaffold] below this scope are currently open or closed.
  bool get isEndDrawerOpen => _isEndDrawerOpen;

  /// Indicates whether the end drawers in the [AdaptiveScaffold] below this scope are currently open or closed.
  set isEndDrawerOpen(bool value) {
    if (_isEndDrawerOpen != value) {
      _isEndDrawerOpen = value;
      notifyListeners();
    }
  }
}

class AdaptiveScaffoldScope
    extends SubChangeNotifierProvider0<AdaptiveScaffoldController> {
  AdaptiveScaffoldScope({
    bool isDrawerOpen = true,
    bool isEndDrawerOpen = true,
  }) : super(
          create: (context) => AdaptiveScaffoldController(
            isDrawerOpen: isDrawerOpen,
            isEndDrawerOpen: isEndDrawerOpen,
          ),
          keys: (context) => [isDrawerOpen, isEndDrawerOpen],
        );
}
