import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoHandler {
  // To prevent the app from crashing due tue OutOfMemoryErrors,
  // the list of all loaded videos is global.
  static final Map<VideoConfig, VideoPlayerController> _videos = {};

  final int maxLoaded = 3;
  // 50mb
  final int maxSize = 5 * pow(10, 7).toInt();

  final Mutex _loadingLock = Mutex();

  VideoHandler({bool muteVideos = false}) : _muteVideos = muteVideos;

  static VideoHandler of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VideoHandlerData>()!.handler;

  bool _muteVideos;
  bool get muteVideos => _muteVideos;
  set muteVideos(bool value) {
    _muteVideos = value;
    _videos.values.forEach((e) => e.setVolume(muteVideos ? 0 : 1));
  }

  VideoPlayerController getVideo(VideoConfig key) => _videos.putIfAbsent(
        key,
        () => VideoPlayerController.network(
          key.url,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        ),
      );

  Future<void> loadVideo(VideoConfig key) async {
    await _loadingLock.acquire();
    VideoPlayerController? controller = getVideo(key);
    if (controller.value.isInitialized) {
      _loadingLock.release();
      return;
    }

    while (true) {
      Map<VideoConfig, VideoPlayerController> loaded = Map.of(_videos)
        ..removeWhere((key, value) => !value.value.isInitialized);
      int loadedSize =
          loaded.keys.fold<int>(0, (current, config) => current + config.size);
      if (loaded.length < maxLoaded && loadedSize < maxSize) {
        break;
      }
      await disposeVideo(loaded.keys.first);
    }

    controller.addListener(controller.wakelock);
    await controller.setLooping(true);
    await controller.setVolume(muteVideos ? 0 : 1);
    await controller.initialize();
    _loadingLock.release();
  }

  Future<void> disposeVideo(VideoConfig key) async {
    VideoPlayerController? controller = _videos[key];
    if (controller != null) {
      await controller.pause();
      controller.removeListener(controller.wakelock);
      await controller.dispose();
      _videos.remove(key);
    }
  }
}

class VideoHandlerData extends InheritedWidget {
  final VideoHandler handler;

  const VideoHandlerData({required this.handler, required super.child});

  @override
  bool updateShouldNotify(covariant VideoHandlerData oldWidget) =>
      oldWidget.handler != handler;
}

extension Wake on VideoPlayerController {
  Future<void> wakelock() async {
    value.isPlaying ? Wakelock.enable() : Wakelock.disable();
  }
}

class VideoHandlerVolumeControl extends StatefulWidget {
  final VideoPlayerController videoController;

  const VideoHandlerVolumeControl({required this.videoController});

  @override
  State<VideoHandlerVolumeControl> createState() =>
      _VideoHandlerVolumeControlState();
}

class _VideoHandlerVolumeControlState extends State<VideoHandlerVolumeControl> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: widget.videoController,
      selector: () => [
        widget.videoController.value.volume,
      ],
      builder: (context, child) {
        bool muted = VideoHandler.of(context).muteVideos;
        return InkWell(
          onTap: () => VideoHandler.of(context).muteVideos = !muted,
          child: Padding(
            padding: const EdgeInsets.all(4),
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

class VideoConfig {
  final String url;
  final int size;

  const VideoConfig({required this.url, required this.size});

  @override
  operator ==(Object other) =>
      other is VideoConfig && other.url == url && other.size == size;

  @override
  int get hashCode => hashValues(url.hashCode, size.hashCode);
}
