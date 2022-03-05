import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoButton extends StatefulWidget {
  final VideoPlayerController videoController;
  final FrameController? frameController;
  final double size;

  VideoButton(
      {required this.videoController, this.frameController, this.size = 54})
      : super(key: ObjectKey(videoController));

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
        bool shown = !widget.videoController.value.isPlaying || loading;
        if (widget.frameController != null) {
          shown = widget.frameController!.visible || shown;
        }

        return FrameFadeWidget(
          shown: shown,
          child: Material(
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
                        color: Colors.white,
                      ),
                      secondChild: Center(
                        child: SizedBox(
                          height: widget.size * 0.7,
                          width: widget.size * 0.7,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
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
          ),
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
      child: FrameFadeWidget(
        controller: frameController,
        child: AnimatedBuilder(
          animation: videoController,
          builder: (context, child) {
            return CrossFade.builder(
              showChild: videoController.value.isInitialized,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VideoGlobalVolumeControl(
                            videoController: videoController,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            videoController.value.position
                                .toString()
                                .substring(2, 7),
                          ),
                          Flexible(
                              child: Slider(
                            min: 0,
                            max: videoController.value.duration.inMilliseconds
                                .toDouble(),
                            value: videoController.value.position.inMilliseconds
                                .toDouble()
                                .clamp(
                                  0,
                                  videoController.value.duration.inMilliseconds
                                      .toDouble(),
                                ),
                            onChangeStart: (double value) {
                              frameController?.cancel();
                            },
                            onChanged: (double value) {
                              videoController.seekTo(
                                  Duration(milliseconds: value.toInt()));
                            },
                            onChangeEnd: (double value) {
                              if (videoController.value.isPlaying) {
                                frameController?.hideFrame(
                                    duration: Duration(seconds: 2));
                              }
                            },
                          )),
                          Text(
                            videoController.value.duration
                                .toString()
                                .substring(2, 7),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            onTap: Navigator.of(context).maybePop,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.fullscreen_exit,
                                size: 24,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
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
            icon: Icon(
              widget.forward ? Icons.fast_forward : Icons.fast_rewind,
              color: Colors.white,
            ),
            title: Text(
              '${10 * combo} seconds',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            double size = constraints.maxHeight * 2;
            return AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) => SizedBox(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: widget.forward ? null : constraints.maxWidth * 0.2,
                      left: widget.forward ? constraints.maxWidth * 0.2 : null,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Theme.of(context).splashColor,
                          borderRadius: widget.forward
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(size),
                                  bottomLeft: Radius.circular(size),
                                )
                              : BorderRadius.only(
                                  topRight: Radius.circular(size),
                                  bottomRight: Radius.circular(size),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        ]),
      ),
    );
  }
}

class VideoGestures extends StatefulWidget {
  final Widget child;
  final VideoPlayerController videoController;

  const VideoGestures({required this.videoController, required this.child});

  @override
  _VideoGesturesState createState() => _VideoGesturesState();
}

class _VideoGesturesState extends State<VideoGestures> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          Positioned.fill(
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
            ),
          ),
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
    if (mounted) {
      setState(() {});
    }
    if (!widget.post.controller!.value.isInitialized) {
      await widget.post.loadVideo();
    }
    if (mounted) {
      setState(() {});
    }
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
        fit: BoxFit.cover,
        showProgress: false,
      );
    }

    if (post.controller != null) {
      return AnimatedBuilder(
        animation: post.controller!,
        builder: (context, child) => post.controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: post.controller!.value.aspectRatio,
                child: VideoPlayer(post.controller!),
              )
            : placeholder(),
      );
    }
    return placeholder();
  }
}

class VideoVolumeControl extends StatefulWidget {
  final VideoPlayerController videoController;

  const VideoVolumeControl({required this.videoController});

  @override
  _VideoVolumeControlState createState() => _VideoVolumeControlState();
}

class _VideoVolumeControlState extends State<VideoVolumeControl> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: widget.videoController,
      selector: () => [
        widget.videoController.value.volume,
        widget.videoController.value.isInitialized
      ],
      builder: (context, child) {
        bool muted = widget.videoController.value.volume == 0;
        return CrossFade(
          showChild: widget.videoController.value.isInitialized,
          child: InkWell(
            onTap: () => widget.videoController.setVolume(muted ? 1 : 0),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                muted ? Icons.volume_off : Icons.volume_up,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoGlobalVolumeControl extends StatefulWidget {
  final VideoPlayerController videoController;

  const VideoGlobalVolumeControl({required this.videoController});

  @override
  _VideoGlobalVolumeControlState createState() =>
      _VideoGlobalVolumeControlState();
}

class _VideoGlobalVolumeControlState extends State<VideoGlobalVolumeControl> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: widget.videoController,
      selector: () => [
        widget.videoController.value.volume,
      ],
      builder: (context, child) {
        bool muted = Post.muteVideos;
        return InkWell(
          onTap: () => setState(() => Post.muteVideos = !muted),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              muted ? Icons.volume_off : Icons.volume_up,
              size: 24,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
