import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScaffoldFrameController extends ValueNotifier<bool> {
  ScaffoldFrameController({this.onToggle, this.visible = false})
      : super(visible);

  final void Function(bool shown)? onToggle;
  Timer? frameToggler;
  bool visible;

  void showFrame({Duration? duration}) =>
      toggleFrame(shown: true, duration: duration);

  void hideFrame({Duration? duration}) =>
      toggleFrame(shown: false, duration: duration);

  void toggleFrame({bool? shown, Duration? duration}) {
    bool result = shown ?? !visible;
    if (result == visible) {
      return;
    }
    frameToggler?.cancel();
    void toggle() {
      visible = result;
      notifyListeners();
      onToggle?.call(visible);
    }

    if (duration == null) {
      toggle();
    } else {
      frameToggler = Timer(duration, toggle);
    }
  }

  void cancel() => frameToggler?.cancel();

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

class ScaffoldFrame extends StatefulWidget {
  const ScaffoldFrame({super.key, required this.child, this.controller});

  final Widget child;
  final ScaffoldFrameController? controller;

  static ScaffoldFrameController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ScaffoldFrameData>()!
      .notifier!;

  static ScaffoldFrameController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ScaffoldFrameData>()
      ?.notifier;

  @override
  State<ScaffoldFrame> createState() => _ScaffoldFrameState();
}

class _ScaffoldFrameState extends State<ScaffoldFrame> {
  late ScaffoldFrameController controller =
      widget.controller ?? ScaffoldFrameController();

  @override
  void didUpdateWidget(covariant ScaffoldFrame oldWidget) {
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? ScaffoldFrameController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ScaffoldFrameData(
        controller: controller,
        child: widget.child,
      );
}

class _ScaffoldFrameData extends InheritedNotifier<ScaffoldFrameController> {
  const _ScaffoldFrameData({
    required super.child,
    required ScaffoldFrameController controller,
  }) : super(notifier: controller);
}

class ScaffoldFrameChild extends StatelessWidget {
  const ScaffoldFrameChild({required this.child, this.shown});

  final bool? shown;
  final Widget child;

  final Duration fadeOutDuration = const Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    ScaffoldFrameController? controller = ScaffoldFrame.maybeOf(context);
    bool shown = this.shown ?? controller?.visible ?? true;

    Widget body() {
      return AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: fadeOutDuration,
        child: ExcludeFocus(
          excluding: !shown,
          child: IgnorePointer(
            ignoring: !shown,
            child: child,
          ),
        ),
      );
    }

    if (controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) => body(),
        child: child,
      );
    } else {
      return body();
    }
  }
}

class ScaffoldFrameAppBar extends StatelessWidget with AppBarBuilderWidget {
  const ScaffoldFrameAppBar({required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) => ScaffoldFrameChild(child: child);
}

class ScaffoldFrameSystemUI extends StatefulWidget {
  const ScaffoldFrameSystemUI({super.key, required this.child});

  final Widget child;

  @override
  State<ScaffoldFrameSystemUI> createState() => _ScaffoldFrameSystemUIState();
}

class _ScaffoldFrameSystemUIState extends State<ScaffoldFrameSystemUI>
    with RouteAware {
  late RouterDrawerController navigation;

  Future<void> toggleFrame(bool shown) async {
    if (shown) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIChangeCallback(
        (shown) async => ScaffoldFrame.of(context).toggleFrame(shown: shown));
  }

  @override
  void didPop() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigation = context.watch<RouterDrawerController>();
    navigation.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    navigation.routeObserver.unsubscribe(this);
    SystemChrome.setSystemUIChangeCallback(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableListener(
      initialize: true,
      listenable: ScaffoldFrame.of(context),
      listener: () => toggleFrame(ScaffoldFrame.of(context).visible),
      child: widget.child,
    );
  }
}
