import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'appbar.dart';

class FrameController extends ChangeNotifier {
  FrameController({this.onToggle, this.visible = false});

  final void Function(bool shown)? onToggle;
  Timer? frameToggler;
  bool visible;

  static FrameController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FrameData>()?.notifier;

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

class FrameData extends InheritedNotifier<FrameController> {
  const FrameData({required super.child, required FrameController controller})
      : super(notifier: controller);
}

class PostFullscreenFrame extends StatefulWidget {
  const PostFullscreenFrame({
    required this.child,
    required this.post,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.controller,
    this.visible,
  }) : assert(visible == null || controller == null);

  final Post post;
  final Widget child;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FrameController? controller;
  final bool? visible;

  @override
  State<PostFullscreenFrame> createState() => _PostFullscreenFrameState();
}

class _PostFullscreenFrameState extends State<PostFullscreenFrame>
    with RouteAware {
  late FrameController controller =
      widget.controller ?? FrameController(visible: widget.visible ?? false);
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
        (hidden) async => controller.toggleFrame(shown: hidden));
  }

  @override
  void didPop() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigation = context.watch<RouterDrawerController>();
    navigation.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    navigation.routeObserver.unsubscribe(this);
    SystemChrome.setSystemUIChangeCallback(null);
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(PostFullscreenFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      controller.cancel();
    } else {
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? FrameController();
      SystemChrome.setSystemUIChangeCallback(
          (hidden) async => controller.toggleFrame(shown: !hidden));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableListener(
      initialize: true,
      listenable: controller,
      listener: () => toggleFrame(controller.visible),
      child: FrameData(
        controller: controller,
        child: AnimatedBuilder(
          animation: controller,
          child: widget.child,
          builder: (contex, child) => AdaptiveScaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: FrameAppBar(
              child: PostFullscreenAppBar(post: widget.post),
            ),
            drawer: widget.drawer,
            endDrawer: widget.endDrawer,
            bottomNavigationBar: widget.post.getVideo(context) != null
                ? VideoBar(
                    videoController: widget.post.getVideo(context)!,
                  )
                : null,
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.toggleFrame();
                if ((widget.post.getVideo(context)?.value.isPlaying ?? false) &&
                    controller.visible) {
                  controller.hideFrame(duration: const Duration(seconds: 2));
                }
              },
              child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: [
                  child!,
                  if (widget.post.getVideo(context) != null)
                    VideoButton(
                      videoController: widget.post.getVideo(context)!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FrameChild extends StatelessWidget {
  const FrameChild({required this.child, this.shown});

  final bool? shown;
  final Widget child;

  final Duration fadeOutDuration = const Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    FrameController? controller = FrameController.of(context);
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

class FrameAppBar extends StatelessWidget with AppBarBuilderWidget {
  const FrameAppBar({required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return FrameChild(
      child: child,
    );
  }
}
