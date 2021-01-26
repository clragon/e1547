import 'dart:async';

import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';

class VideoFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final bool showFrame;
  final Function(bool shown) onFrameToggle;

  VideoFrame(
      {@required this.child,
      @required this.post,
      this.onFrameToggle,
      this.showFrame});

  @override
  _VideoFrameState createState() => _VideoFrameState();
}

class _VideoFrameState extends State<VideoFrame> {
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  Timer frameToggler;

  void toggleFrame({bool shown}) {
    frameToggler?.cancel();
    showFrame.value = shown ?? !showFrame.value;
    widget.onFrameToggle?.call(shown);
  }

  @override
  void didUpdateWidget(VideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    frameToggler?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    frameToggler?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomBar() {
      return ValueListenableBuilder(
        valueListenable: showFrame,
        builder: (context, value, child) => CrossFade(
          duration: Duration(milliseconds: 200),
          showChild: value,
          child: child,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ValueListenableBuilder(
            valueListenable: widget.post.controller,
            builder: (context, controller, child) {
              if (controller.initialized) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.position.toString().substring(2, 7)),
                      Flexible(
                          child: Slider(
                        min: 0,
                        max: controller.duration.inMilliseconds.toDouble(),
                        value: controller.position.inMilliseconds.toDouble(),
                        onChangeStart: (double value) {
                          frameToggler?.cancel();
                        },
                        onChanged: (double value) {
                          widget.post.controller
                              .seekTo(Duration(milliseconds: value.toInt()));
                        },
                        onChangeEnd: (double value) {
                          if (widget.post.controller.value.isPlaying) {
                            frameToggler = Timer(Duration(seconds: 2), () {
                              toggleFrame(shown: false);
                            });
                          }
                        },
                      )),
                      Text(controller.duration.toString().substring(2, 7)),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.fullscreen_exit,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        onTap: Navigator.of(context).maybePop,
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          )
        ]),
      );
    }

    Widget playButton() {
      return ValueListenableBuilder(
          valueListenable: widget.post.controller,
          builder: (context, controller, child) {
            return ValueListenableBuilder(
              valueListenable: showFrame,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity:
                      value || !widget.post.controller.value.isPlaying ? 1 : 0,
                  child: value || !widget.post.controller.value.isPlaying
                      ? child
                      : IgnorePointer(child: child),
                );
              },
              child: InkWell(
                onTap: () {
                  frameToggler?.cancel();
                  if (controller.isPlaying) {
                    widget.post.controller.pause();
                  } else {
                    widget.post.controller.play();
                    frameToggler = Timer(Duration(milliseconds: 500), () {
                      toggleFrame(shown: false);
                    });
                  }
                },
                child: CrossFade(
                  duration: Duration(milliseconds: 100),
                  showChild: controller.isPlaying,
                  child: CrossFade(
                    duration: Duration(milliseconds: 100),
                    showChild:
                        controller.initialized && !controller.isBuffering,
                    child: IconShadowWidget(
                      Icon(
                        Icons.pause,
                        size: 54,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      shadowColor: Colors.black,
                    ),
                    secondChild: Container(
                      height: 54,
                      width: 54,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  secondChild: IconShadowWidget(
                    Icon(
                      Icons.play_arrow,
                      size: 54,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    shadowColor: Colors.black,
                  ),
                ),
              ),
            );
          });
    }

    List<Widget> children = [widget.child];
    if (widget.post.type == ImageType.Video) {
      children.addAll([
        Positioned(bottom: 0, right: 0, left: 0, child: bottomBar()),
        playButton(),
      ]);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        toggleFrame();
        if ((widget.post.controller?.value?.isPlaying ?? false) &&
            showFrame.value) {
          frameToggler =
              Timer(Duration(seconds: 2), () => toggleFrame(shown: false));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }
}
