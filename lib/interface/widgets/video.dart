import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:wakelock/wakelock.dart';

class VideoHandler extends ChangeNotifier {
  VideoHandler({bool muteVideos = false}) : _muteVideos = muteVideos;

  static VideoHandler of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VideoHandlerData>()!.handler;

  // To prevent the app from crashing due tue OutOfMemoryErrors,
  // the list of all loaded videos is global.
  static final Map<VideoConfig, CachedVideoPlayerController> _videos = {};

  final int maxLoaded = 3;

  // 50mb
  final int maxSize = 5 * pow(10, 7).toInt();

  final Mutex _loadingLock = Mutex();

  bool _muteVideos;

  bool get muteVideos => _muteVideos;

  set muteVideos(bool value) {
    _muteVideos = value;
    _videos.values.forEach((e) => e.setVolume(muteVideos ? 0 : 1));
    notifyListeners();
  }

  CachedVideoPlayerController getVideo(VideoConfig key) => _videos.putIfAbsent(
        key,
        () => CachedVideoPlayerController.network(
          key.url,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        ),
      );

  Future<void> loadVideo(VideoConfig key) async {
    await _loadingLock.acquire();
    CachedVideoPlayerController? controller = getVideo(key);
    if (controller.value.isInitialized) {
      _loadingLock.release();
      return;
    }

    while (true) {
      Map<VideoConfig, CachedVideoPlayerController> loaded = Map.of(_videos)
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
    notifyListeners();
  }

  Future<void> disposeVideo(VideoConfig key) async {
    CachedVideoPlayerController? controller = _videos[key];
    if (controller != null) {
      await controller.pause();
      controller.removeListener(controller.wakelock);
      await controller.dispose();
      _videos.remove(key);
      notifyListeners();
    }
  }
}

class VideoHandlerData extends InheritedNotifier<VideoHandler> {
  const VideoHandlerData({required this.handler, required super.child})
      : super(notifier: handler);

  final VideoHandler handler;

  @override
  bool updateShouldNotify(covariant VideoHandlerData oldWidget) =>
      oldWidget.handler != handler;
}

extension Wake on CachedVideoPlayerController {
  void wakelock() {
    value.isPlaying ? Wakelock.enable() : Wakelock.disable();
  }
}

class VideoHandlerVolumeControl extends StatefulWidget {
  const VideoHandlerVolumeControl();

  @override
  State<VideoHandlerVolumeControl> createState() =>
      _VideoHandlerVolumeControlState();
}

class _VideoHandlerVolumeControlState extends State<VideoHandlerVolumeControl> {
  @override
  Widget build(BuildContext context) {
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
  }
}

@immutable
class VideoConfig {
  const VideoConfig({required this.url, required this.size});

  final String url;
  final int size;

  @override
  bool operator ==(Object other) =>
      other is VideoConfig && other.url == url && other.size == size;

  @override
  int get hashCode => Object.hash(url.hashCode, size.hashCode);
}
