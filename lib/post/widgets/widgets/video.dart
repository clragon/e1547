import 'dart:async';

import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FrameController extends ChangeNotifier {
  bool visible;
  Timer? frameToggler;
  void Function(bool shown)? onToggle;
  Duration defaultFrameDuration = Duration(seconds: 1);

  FrameController({this.onToggle, this.visible = false});

  void showFrame({required Duration duration}) {
    toggleFrame(shown: true, duration: duration);
  }

  void hideFrame({required Duration duration}) {
    toggleFrame(shown: false, duration: duration);
  }

  void toggleFrame({bool? shown, Duration? duration}) {
    frameToggler?.cancel();
    void toggle() {
      visible = shown ?? !visible;
      this.notifyListeners();
      onToggle?.call(visible);
    }

    if (duration?.inMicroseconds == 0) {
      toggle();
    } else {
      frameToggler = Timer(duration ?? defaultFrameDuration, toggle);
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

class VideoFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final bool? showFrame;
  final Function(bool shown)? onToggle;

  VideoFrame(
      {required this.child, required this.post, this.onToggle, this.showFrame});

  @override
  _VideoFrameState createState() => _VideoFrameState();
}

class _VideoFrameState extends State<VideoFrame> {
  late FrameController frameController;

  @override
  void initState() {
    super.initState();
    frameController = FrameController(
      onToggle: widget.onToggle,
    );
  }

  @override
  void didUpdateWidget(VideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    frameController.cancel();
  }

  @override
  void dispose() {
    frameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        frameController,
        widget.post.controller,
      ]),
      builder: (contex, child) {
        List<Widget> children = [
          widget.child,
        ];

        if (widget.post.controller != null) {
          children.addAll([
            Positioned.fill(
              child: VideoGestures(videoController: widget.post.controller!),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: VideoBar(
                videoController: widget.post.controller!,
                frameController: frameController,
              ),
            ),
            VideoButton(
              videoController: widget.post.controller!,
              frameController: frameController,
            )
          ]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            frameController.toggleFrame(duration: Duration(seconds: 0));
            if ((widget.post.controller?.value.isPlaying ?? false) &&
                frameController.visible) {
              frameController.hideFrame(duration: Duration(seconds: 2));
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

class VideoButton extends StatefulWidget {
  final VideoPlayerController videoController;
  final FrameController? frameController;
  final double size;

  const VideoButton(
      {required this.videoController, this.frameController, this.size = 54});

  @override
  _VideoButtonState createState() => _VideoButtonState();
}

class _VideoButtonState extends State<VideoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: defaultAnimationDuration);

  void videoUpdate() {
    if (widget.videoController.value.isPlaying) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.videoController.addListener(videoUpdate);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.videoController.removeListener(videoUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        animationController,
        widget.videoController,
        widget.frameController
      ]),
      builder: (context, child) {
        bool loading = !widget.videoController.value.isInitialized ||
            widget.videoController.value.isBuffering;

        Widget button() {
          return Material(
            shape: CircleBorder(),
            color: Colors.transparent,
            elevation: 8,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Material(
                type: MaterialType.transparency,
                shape: CircleBorder(),
                child: IconButton(
                  iconSize: widget.size,
                  icon: Center(
                    child: Replacer(
                      duration: Duration(milliseconds: 100),
                      showChild:
                          !widget.videoController.value.isPlaying || !loading,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: animationController,
                        size: widget.size,
                      ),
                      secondChild: Container(
                        height: widget.size * 0.7,
                        width: widget.size * 0.7,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (widget.videoController.value.isPlaying) {
                      widget.frameController?.cancel();
                      widget.videoController.pause();
                    } else {
                      widget.videoController.play();
                      widget.frameController
                          ?.hideFrame(duration: Duration(milliseconds: 500));
                    }
                  },
                ),
              ),
            ),
          );
        }

        bool shown = !widget.videoController.value.isPlaying || loading;
        if (widget.frameController != null) {
          shown = widget.frameController!.visible || shown;
        }

        return AnimatedOpacity(
          duration: defaultAnimationDuration,
          opacity: shown ? 1 : 0,
          child: IgnorePointer(child: button(), ignoring: !shown),
        );
      },
    );
  }
}

class VideoBar extends StatelessWidget {
  final VideoPlayerController videoController;
  final FrameController? frameController;

  const VideoBar(
      {required this.videoController, required this.frameController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          videoController,
          frameController,
        ]),
        builder: (context, child) {
          bool shown =
              frameController!.visible && videoController.value.isInitialized;

          return SafeCrossFade(
            showChild: shown,
            builder: (context) => IgnorePointer(
              ignoring: !shown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(videoController.value.position
                            .toString()
                            .substring(2, 7)),
                        Flexible(
                            child: Slider(
                          min: 0,
                          max: videoController.value.duration.inMilliseconds
                              .toDouble(),
                          value: videoController.value.position.inMilliseconds
                              .toDouble(),
                          onChangeStart: (double value) {
                            frameController!.cancel();
                          },
                          onChanged: (double value) {
                            videoController
                                .seekTo(Duration(milliseconds: value.toInt()));
                          },
                          onChangeEnd: (double value) {
                            if (videoController.value.isPlaying) {
                              frameController!
                                  .hideFrame(duration: Duration(seconds: 2));
                            }
                          },
                        )),
                        Text(videoController.value.duration
                            .toString()
                            .substring(2, 7)),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoGesture extends StatefulWidget {
  final bool forward;
  final VideoPlayerController videoController;
  const VideoGesture({required this.forward, required this.videoController});

  @override
  _VideoGestureState createState() => _VideoGestureState();
}

class _VideoGestureState extends State<VideoGesture>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  late final Animation<double> fadeAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  );
  int combo = 0;
  Timer? comboReset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: () async {
        if (widget.videoController.value.isInitialized) {
          Duration current = (await widget.videoController.position)!;
          bool boundOnZero = current == Duration.zero;
          // for inexplicable reasons, duration will be a single ms ahead
          bool boundOnEnd = current ==
              widget.videoController.value.duration - Duration(milliseconds: 1);
          if ((!widget.forward && boundOnZero) ||
              (widget.forward && boundOnEnd)) {
            return;
          }

          Duration target = current;
          if (widget.forward) {
            target += Duration(seconds: 10);
          } else {
            target -= Duration(seconds: 10);
          }
          setState(() {
            combo++;
          });

          widget.videoController.seekTo(target);
          comboReset?.cancel();
          comboReset = Timer(
              Duration(milliseconds: 900), () => setState(() => combo = 0));
          await animationController.forward();
          await animationController.reverse();
        }
      },
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Stack(children: [
          IconMessage(
            icon: Icon(widget.forward ? Icons.fast_forward : Icons.fast_rewind),
            title: Text('${10 * combo} seconds'),
          ),
          AnimatedBuilder(
            animation: fadeAnimation,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.6 * animationController.value),
                  ],
                  begin: widget.forward
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  end: widget.forward
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class VideoGestures extends StatefulWidget {
  final VideoPlayerController videoController;

  const VideoGestures({required this.videoController});

  @override
  _VideoGesturesState createState() => _VideoGesturesState();
}

class _VideoGesturesState extends State<VideoGestures> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: VideoGesture(
                  forward: false,
                  videoController: widget.videoController,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.1,
              ),
              Expanded(
                child: VideoGesture(
                  forward: true,
                  videoController: widget.videoController,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}

class PostVideoLoader extends StatefulWidget {
  final Post post;
  final Widget child;

  const PostVideoLoader({required this.post, required this.child});

  @override
  _PostVideoLoaderState createState() => _PostVideoLoaderState();
}

class _PostVideoLoaderState extends State<PostVideoLoader> {
  Future<void> ensureVideo() async {
    if (widget.post.controller == null) {
      await widget.post.initVideo();
    }
    if (!widget.post.controller!.value.isInitialized) {
      await widget.post.loadVideo();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ensureVideo();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PostVideoWidget extends StatelessWidget {
  final Post post;

  const PostVideoWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    Widget placeholder() {
      return PostImageWidget(
        post: post,
        size: ImageSize.sample,
        showProgress: false,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: SafeCrossFade(
            showChild: post.controller != null,
            builder: (context) => AnimatedBuilder(
              animation: post.controller!,
              builder: (context, child) => CrossFade(
                showChild: post.controller!.value.isInitialized,
                child: AspectRatio(
                  aspectRatio: post.controller!.value.aspectRatio,
                  child: VideoPlayer(post.controller!),
                ),
                secondChild: placeholder(),
              ),
            ),
            secondChild: placeholder(),
          ),
        ),
      ],
    );
  }
}
