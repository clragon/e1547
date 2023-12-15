import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:rxdart/rxdart.dart';

class VideoButton extends StatelessWidget {
  const VideoButton({super.key, required this.player, this.size = 54});

  final VideoPlayer player;
  final double size;

  @override
  Widget build(BuildContext context) {
    ScaffoldFrameController? frameController = ScaffoldFrame.maybeOf(context);
    return SubStream<List<bool>>(
      create: () => CombineLatestStream.list([
        player.stream.playing.startWith(player.state.playing),
        player.stream.buffering.startWith(player.state.buffering),
        player.initialized.startWith(player.isInitialized),
      ]),
      keys: [player],
      builder: (context, states) => SubAnimationController(
        duration: defaultAnimationDuration,
        keys: [player],
        builder: (context, animationController) => AnimatedBuilder(
          animation: Listenable.merge([frameController]),
          builder: (context, child) {
            final [playing, buffering, initialized] = states.data ??
                [
                  player.state.playing,
                  player.state.buffering,
                  player.isInitialized
                ];

            bool loading = !initialized || buffering;
            bool alwaysVisible = !playing || loading;
            bool shown = alwaysVisible || (frameController?.visible ?? false);
            bool showPlayButton = !playing || (playing && !loading);

            return ScaffoldFrameChild(
              shown: shown,
              child: Material(
                clipBehavior: Clip.antiAlias,
                shape: const CircleBorder(),
                color: Colors.black26,
                child: IconButton(
                  iconSize: size,
                  onPressed: () {
                    if (player.state.playing) {
                      frameController?.cancel();
                      player.pause();
                    } else {
                      player.play();
                      frameController?.hideFrame(
                          duration: const Duration(milliseconds: 500));
                    }
                  },
                  icon: Center(
                    child: CrossFade(
                      showChild: showPlayButton,
                      duration: const Duration(milliseconds: 100),
                      secondChild: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      child: SubValue<StreamSubscription<bool>>(
                        create: () {
                          if (player.state.playing) {
                            animationController.forward();
                          } else {
                            animationController.reverse();
                          }
                          return player.stream.playing.listen((event) {
                            if (event) {
                              animationController.forward();
                            } else {
                              animationController.reverse();
                            }
                          });
                        },
                        keys: [player, animationController],
                        dispose: (value) => value.cancel(),
                        builder: (context, _) => AnimatedBuilder(
                          animation: animationController,
                          builder: (context, child) => AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: animationController,
                            size: size,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class VideoBar extends StatefulWidget {
  const VideoBar({super.key, required this.player});

  final VideoPlayer player;

  @override
  State<VideoBar> createState() => _VideoBarState();
}

class _VideoBarState extends State<VideoBar> {
  bool playing = false;
  bool seeking = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Duration buffer = Duration.zero;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    playing = widget.player.state.playing;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    buffer = widget.player.state.buffer;
    subscriptions.addAll(
      [
        widget.player.stream.playing.listen((event) {
          setState(() {
            playing = event;
          });
        }),
        widget.player.stream.completed.listen((event) {
          setState(() {
            position = Duration.zero;
          });
        }),
        widget.player.stream.position.listen((event) {
          setState(() {
            if (!seeking) position = event;
          });
        }),
        widget.player.stream.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.player.stream.buffer.listen((event) {
          setState(() {
            buffer = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaffoldFrameChild(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VideoServiceVolumeControl(),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(position.toString().substring(2, 7)),
                  Flexible(
                    child: Slider(
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.toDouble().clamp(
                            0.0,
                            duration.inMilliseconds.toDouble(),
                          ),
                      secondaryTrackValue:
                          buffer.inMilliseconds.toDouble().clamp(
                                0.0,
                                duration.inMilliseconds.toDouble(),
                              ),
                      onChangeStart: (e) {
                        seeking = true;
                        ScaffoldFrame.maybeOf(context)
                            ?.toggleFrame(shown: true);
                      },
                      onChanged: position.inMilliseconds > 0
                          ? (e) {
                              setState(() {
                                position = Duration(milliseconds: e ~/ 1);
                              });
                            }
                          : null,
                      onChangeEnd: (e) {
                        seeking = false;
                        widget.player.seek(Duration(milliseconds: e ~/ 1));
                        ScaffoldFrame.maybeOf(context)
                            ?.toggleFrame(shown: false);
                      },
                    ),
                  ),
                  Text(duration.toString().substring(2, 7)),
                  const SizedBox(
                    width: 4,
                  ),
                  InkWell(
                    onTap: Navigator.of(context).maybePop,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
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
        ),
      ),
    );
  }
}

class VideoGesture extends StatefulWidget {
  const VideoGesture({
    super.key,
    required this.forward,
    required this.player,
  });

  final bool forward;
  final VideoPlayer player;

  @override
  State<VideoGesture> createState() => _VideoGestureState();
}

class _VideoGestureState extends State<VideoGesture>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
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
        Duration current = widget.player.state.position;
        bool boundOnZero = current == Duration.zero;
        bool boundOnEnd = current == widget.player.state.duration;
        if ((!widget.forward && boundOnZero) ||
            (widget.forward && boundOnEnd)) {
          return;
        }

        Duration target = current;
        if (widget.forward) {
          target += const Duration(seconds: 10);
        } else {
          target -= const Duration(seconds: 10);
        }
        setState(() {
          combo++;
        });

        widget.player.seek(target);
        comboReset?.cancel();
        comboReset = Timer(
            const Duration(milliseconds: 900), () => setState(() => combo = 0));
        await animationController.forward();
        await animationController.reverse();
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
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            double size = constraints.maxHeight * 2;
            return AnimatedBuilder(
              animation: fadeAnimation,
              builder: (context, child) => Stack(
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
            );
          })
        ]),
      ),
    );
  }
}

class VideoGestures extends StatelessWidget {
  const VideoGestures({
    super.key,
    required this.player,
    required this.child,
  });

  final Widget child;
  final VideoPlayer player;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: VideoGesture(
                    forward: false,
                    player: player,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.1,
                ),
                Expanded(
                  child: VideoGesture(
                    forward: true,
                    player: player,
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

class PostVideoRoute extends StatefulWidget {
  const PostVideoRoute({
    super.key,
    required this.child,
    required this.post,
    this.stopOnDispose = true,
  });

  final Widget child;
  final Post post;
  final bool stopOnDispose;

  static PostVideoRouteState of(BuildContext context) =>
      context.findAncestorStateOfType<PostVideoRouteState>()!;

  static PostVideoRouteState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<PostVideoRouteState>();

  @override
  State<PostVideoRoute> createState() => PostVideoRouteState();
}

class PostVideoRouteState extends State<PostVideoRoute> with RouteAware {
  late VideoPlayer? player;
  late RouterDrawerController _navigation;
  late final bool _wasPlaying;
  bool _keepPlaying = false;

  void keepPlaying() => _keepPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _wasPlaying =
            widget.post.getVideo(context, listen: false)?.state.playing ??
                false;
      }
    });
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (_keepPlaying) {
      _keepPlaying = false;
    } else {
      player?.pause();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigation = context.watch<RouterDrawerController>();
    _navigation.routeObserver.subscribe(this, ModalRoute.of(context)!);
    player = widget.post.getVideo(context);
  }

  @override
  void reassemble() {
    super.reassemble();
    _navigation.routeObserver.unsubscribe(this);
    _navigation.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _navigation.routeObserver.unsubscribe(this);
    if (widget.stopOnDispose && !_wasPlaying) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => player?.pause(),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PostVideoWidget extends StatelessWidget {
  const PostVideoWidget({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    VideoPlayer player = post.getVideo(context)!;

    Widget placeholder() {
      return PostImageWidget(
        post: post,
        size: PostImageSize.sample,
        fit: BoxFit.cover,
        showProgress: false,
        lowResCacheSize: context.watch<ImageCacheSize?>()?.size,
      );
    }

    return SubStream<bool>(
      create: () => player.initialized,
      keys: [player],
      builder: (context, snapshot) {
        bool initialized = snapshot.data ?? player.isInitialized;
        if (!initialized) return placeholder();
        return AspectRatio(
          aspectRatio: post.file.width / post.file.height,
          child: Video(
            controller: player.controller,
            fill: Colors.transparent,
            controls: null,
          ),
        );
      },
    );
  }
}
