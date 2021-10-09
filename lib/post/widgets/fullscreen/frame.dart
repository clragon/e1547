import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

import '../widgets/video.dart';
import 'appbar.dart';

class FrameController extends ChangeNotifier {
  final Duration defaultFrameDuration = Duration(seconds: 1);
  final void Function(bool shown)? onToggle;
  Timer? frameToggler;
  bool visible;

  FrameController({this.onToggle, this.visible = false});

  void showFrame({Duration? duration}) =>
      toggleFrame(shown: true, duration: duration);

  void hideFrame({Duration? duration}) =>
      toggleFrame(shown: false, duration: duration);

  void toggleFrame({bool? shown, Duration? duration}) {
    frameToggler?.cancel();
    void toggle() {
      visible = shown ?? !visible;
      notifyListeners();
      onToggle?.call(visible);
    }

    if (duration == null) {
      toggle();
    } else {
      frameToggler = Timer(duration, toggle);
    }
  }

  void cancel() {
    frameToggler?.cancel();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

class PostFullscreenFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final FrameController? controller;

  const PostFullscreenFrame({
    required this.child,
    required this.post,
    this.controller,
  });

  @override
  _PostFullscreenFrameState createState() => _PostFullscreenFrameState();
}

class _PostFullscreenFrameState extends State<PostFullscreenFrame> {
  late FrameController controller = widget.controller ?? FrameController();

  @override
  void didUpdateWidget(PostFullscreenFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.cancel();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (contex, child) {
        List<Widget> children = [child!];

        if (widget.post.controller != null) {
          children.addAll([
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: VideoBar(
                videoController: widget.post.controller!,
                frameController: controller,
              ),
            ),
            VideoButton(
              videoController: widget.post.controller!,
              frameController: controller,
            )
          ]);
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: CrossFade(
              showChild: controller.visible,
              child: PostFullscreenAppBar(post: widget.post),
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              controller.toggleFrame();
              if ((widget.post.controller?.value.isPlaying ?? false) &&
                  controller.visible) {
                controller.hideFrame(duration: Duration(seconds: 2));
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
