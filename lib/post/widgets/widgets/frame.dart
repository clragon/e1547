import 'dart:async';

import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

import 'video.dart';

class FrameController extends ChangeNotifier {
  final Duration defaultFrameDuration = Duration(seconds: 1);
  final void Function(bool shown)? onToggle;
  Timer? frameToggler;
  bool visible;

  FrameController({this.onToggle, this.visible = false});

  void showFrame({required Duration duration}) =>
      toggleFrame(shown: true, duration: duration);

  void hideFrame({required Duration duration}) =>
      toggleFrame(shown: false, duration: duration);

  void toggleFrame({bool? shown, Duration? duration}) {
    frameToggler?.cancel();
    void toggle() {
      visible = shown ?? !visible;
      this.notifyListeners();
      onToggle?.call(visible);
    }

    frameToggler = Timer(duration ?? defaultFrameDuration, toggle);
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

class PostPhotoFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final FrameController? controller;

  PostPhotoFrame({required this.child, required this.post, this.controller});

  @override
  _PostPhotoFrameState createState() => _PostPhotoFrameState();
}

class _PostPhotoFrameState extends State<PostPhotoFrame> {
  late FrameController controller = widget.controller ?? FrameController();

  @override
  void didUpdateWidget(PostPhotoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.cancel();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        widget.post.controller,
      ]),
      builder: (contex, child) {
        List<Widget> children = [
          widget.child,
        ];

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

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            controller.toggleFrame(duration: Duration.zero);
            if ((widget.post.controller?.value.isPlaying ?? false) &&
                controller.visible) {
              controller.hideFrame(duration: Duration(seconds: 2));
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: children,
          ),
        );
      },
    );
  }
}
