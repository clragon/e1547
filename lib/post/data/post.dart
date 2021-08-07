import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'data.dart';

export 'actions.dart';
export 'image.dart';

class Post extends PostData with ChangeNotifier {
  Map json;

  Map<String, List<String>> get tagMap => {
        "general": tags.general,
        "species": tags.species,
        "character": tags.character,
        "copyright": tags.copyright,
        "artist": tags.artist,
        "invalid": tags.invalid,
        "lore": tags.lore,
        "meta": tags.meta,
      };

  bool isEditing = false;
  bool isLoggedIn = false;
  bool isBlacklisted = false;
  bool isAllowed = false;

  bool get isVisible => (isFavorited || isAllowed || !isBlacklisted);

  VoteStatus voteStatus = VoteStatus.unknown;

  PostType get type {
    switch (file.ext) {
      case 'webm':
        return PostType.Video;
      case 'swf':
        return PostType.Unsupported;
      default:
        return PostType.Image;
    }
  }

  VideoPlayerController? controller;

  static List<Post> loadedVideos = [];

  Future<void> initVideo() async {
    if (type == PostType.Video && file.url != null) {
      if (controller != null) {
        await controller!.pause();
        await controller!.dispose();
      }
      controller = VideoPlayerController.network(file.url!);
      controller!.setLooping(true);
      controller!.addListener(() =>
          controller!.value.isPlaying ? Wakelock.enable() : Wakelock.disable());
    }
  }

  Future<void> loadVideo() async {
    if (type != PostType.Video || loadedVideos.contains(this)) {
      return;
    }
    if (loadedVideos.length >= 6) {
      loadedVideos.first.disposeVideo();
    }
    loadedVideos.add(this);
    await this.controller!.initialize();
  }

  Future<void> disposeVideo() async {
    await initVideo();
    loadedVideos.remove(this);
  }

  List<String> get artists {
    return tags.artist
      ..removeWhere((artist) => [
            'epilepsy_warning',
            'conditional_dnp',
            'sound_warning',
            'avoid_posting',
          ].contains(artist));
  }

  Post.fromMap(this.json) : super.fromMap(json as Map<String, dynamic>) {
    if (type == PostType.Video && Platform.isIOS) {
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

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}

enum PostType {
  Image,
  Video,
  Unsupported,
}
