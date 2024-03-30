import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rxdart/rxdart.dart';

export 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends Player {
  VideoPlayer() {
    controller.waitUntilFirstFrameRendered.then((_) => _initialized.add(true));
    stream.error.first.then((_) => _initialized.add(true));
  }

  late final VideoController _controller = VideoController(this);
  VideoController get controller => _controller;

  final BehaviorSubject<bool> _initialized = BehaviorSubject.seeded(false);
  Stream<bool> get initialized => _initialized.stream;

  bool get isInitialized => _initialized.value;
}

class VideoService extends ChangeNotifier {
  VideoService({bool muteVideos = false}) : _muteVideos = muteVideos;

  static void ensureInitialized() => MediaKit.ensureInitialized();

  // To prevent the app from crashing due tue OutOfMemoryErrors,
  // the list of all loaded videos is global.
  static final Map<String, VideoPlayer> _videos = {};

  final Logger _logger = Logger('Videos');

  final int maxLoaded = 3;

  bool _muteVideos;

  bool get muteVideos => _muteVideos;

  set muteVideos(bool value) {
    _muteVideos = value;
    _videos.values.forEach((e) => e.setVolume(muteVideos ? 0 : 100));
    notifyListeners();
    _logger.fine('${_muteVideos ? 'Muted' : 'Unmuted'} all controllers');
  }

  VideoPlayer getVideo(String key) {
    while (true) {
      Map<String, VideoPlayer> loaded = Map.of(_videos);
      loaded.remove(key);
      if (loaded.length < maxLoaded) break;
      _logger.fine('Too many (${loaded.length}) videos loaded!');
      disposeVideo(loaded.keys.first);
    }
    return _videos.putIfAbsent(
      key,
      () {
        VideoPlayer player = VideoPlayer();
        // TODO: this is missing client auth headers
        player.open(Media(key), play: false);
        player.setPlaylistMode(PlaylistMode.single);
        player.setVolume(_muteVideos ? 0 : 100);
        return player;
      },
    );
  }

  Future<void> disposeVideo(String key) async {
    VideoPlayer? controller = _videos[key];
    if (controller != null) {
      _videos.remove(key);
      await controller.pause();
      await controller.dispose();
      notifyListeners();
      _logger.fine('Unloaded $key');
    }
  }
}

class VideoServiceProvider
    extends SubChangeNotifierProvider<Settings, VideoService> {
  VideoServiceProvider({super.child, super.builder})
      : super(
          create: (context, settings) => VideoService(
            muteVideos: settings.muteVideos.value,
          ),
        );
}

class VideoServiceVolumeControl extends StatelessWidget {
  const VideoServiceVolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    VideoService service = context.watch<VideoService>();
    bool muted = service.muteVideos;
    return InkWell(
      onTap: () => service.muteVideos = !muted,
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

enum VideoResolution {
  standard,
  high,
  full,
  ultra,
  source;

  String get title => switch (this) {
        VideoResolution.standard => 'Standard (480p)',
        VideoResolution.high => 'High (720p)',
        VideoResolution.full => 'Full (1080p)',
        VideoResolution.ultra => 'Ultra (4K)',
        VideoResolution.source => 'Source',
      };

  int get pixels => switch (this) {
        VideoResolution.standard => 640 * 480,
        VideoResolution.high => 1280 * 720,
        VideoResolution.full => 1920 * 1080,
        VideoResolution.ultra => 3840 * 2160,
        VideoResolution.source => 4096 * 2160,
      };
}
