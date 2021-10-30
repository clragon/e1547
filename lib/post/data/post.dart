import 'dart:io';
import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'data.dart';

export 'actions.dart';
export 'image.dart';

class Post extends PostData with ChangeNotifier {
  Map json;

  bool isEditing = false;
  bool isLoggedIn = false;
  bool isBlacklisted = false;
  bool isAllowed = false;

  bool get isVisible => (isFavorited || isAllowed || !isBlacklisted);

  VoteStatus voteStatus = VoteStatus.unknown;

  PostType get type {
    switch (file.ext) {
      case 'mp4':
      case 'webm':
        if (Platform.isWindows) return PostType.unsupported;
        return PostType.video;
      case 'swf':
        return PostType.unsupported;
      default:
        return PostType.image;
    }
  }

  VideoPlayerController? controller;

  static List<Post> loadedVideos = [];
  static bool _muteVideos = settings.muteVideos.value;
  static bool get muteVideos => _muteVideos;
  static set muteVideos(value) {
    _muteVideos = value;
    loadedVideos.forEach(
      (element) => element.controller?.setVolume(muteVideos ? 0 : 1),
    );
  }

  Future<void> wakelock() async {
    controller!.value.isPlaying ? Wakelock.enable() : Wakelock.disable();
  }

  Future<void> initVideo() async {
    if (type == PostType.video && file.url != null) {
      if (controller != null) {
        await controller!.pause();
        controller!.removeListener(wakelock);
        await controller!.dispose();
      }
      controller = VideoPlayerController.network(file.url!);
      controller!.setLooping(true);
      controller!.addListener(wakelock);
    }
  }

  Future<void> loadVideo() async {
    if (type != PostType.video || loadedVideos.contains(this)) {
      return;
    }

    if (loadedVideos.length >= 6) {
      loadedVideos.first.disposeVideo();
    }

    while (true) {
      if (loadedVideos.fold<int>(
              0, (current, post) => current += post.file.size) <
          2 * pow(10, 8)) {
        break;
      }
      await loadedVideos.first.disposeVideo();
    }

    loadedVideos.add(this);
    await controller!.initialize();
    await controller!.setVolume(muteVideos ? 0 : 1);
  }

  Future<void> disposeVideo() async {
    await initVideo();
    loadedVideos.remove(this);
  }

  List<String> get artists {
    List<String> excluded = [
      'epilepsy_warning',
      'conditional_dnp',
      'sound_warning',
      'avoid_posting',
    ];

    return List.from(tags['artist']!)
      ..removeWhere((artist) => excluded.contains(artist));
  }

  Post.fromMap(this.json) : super.fromMap(json as Map<String, dynamic>) {
    if (type == PostType.video && Platform.isIOS) {
      file.ext = 'mp4';
      file.url = file.url!.replaceAll('.webm', '.mp4');
    }
    initVideo();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  dispose() {
    disposeVideo();
    super.dispose();
  }
}

enum PostType {
  image,
  video,
  unsupported,
}
