import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'image.dart';

export 'actions.dart';
export 'image.dart';

class Post {
  Map raw;

  int id;

  int uploader;
  String creation;
  String updated;

  List<int> pools = [];
  List<int> children = [];

  bool isDeleted = false;
  bool isLoggedIn = false;
  bool isBlacklisted = false;

  ValueNotifier<PostImage> preview = ValueNotifier(null);
  ValueNotifier<PostImage> sample = ValueNotifier(null);
  ValueNotifier<PostImageFile> file = ValueNotifier(null);

  ValueNotifier<Map<String, List<String>>> tags = ValueNotifier({});

  ValueNotifier<int> comments = ValueNotifier(null);
  ValueNotifier<int> score = ValueNotifier(null);
  ValueNotifier<int> favorites = ValueNotifier(null);
  ValueNotifier<int> parent = ValueNotifier(null);

  ValueNotifier<String> rating = ValueNotifier(null);
  ValueNotifier<String> description = ValueNotifier(null);

  ValueNotifier<List<String>> sources = ValueNotifier([]);

  ValueNotifier<bool> isFavorite = ValueNotifier(false);
  ValueNotifier<bool> isEditing = ValueNotifier(false);
  ValueNotifier<bool> showUnsafe = ValueNotifier(false);

  bool get isVisible =>
      (isFavorite.value || showUnsafe.value || !isBlacklisted);

  ValueNotifier<VoteStatus> voteStatus = ValueNotifier(VoteStatus.unknown);

  static List<Post> loadedVideos = [];

  VideoPlayerController controller;

  ImageType type;

  List<String> get artists {
    return tags.value['artist']
      ..removeWhere((artist) => [
            'epilepsy_warning',
            'conditional_dnp',
            'sound_warning',
            'avoid_posting',
          ].contains(artist));
  }

  Post.fromMap(this.raw) {
    id = raw['id'];
    isDeleted = raw['flags']['deleted'];
    creation = raw['created_at'];
    updated = raw['updated_at'];
    uploader = raw['uploader_id'];
    children = List<int>.from(raw["relationships"]['children']);
    pools = List<int>.from(raw['pools']).toSet().toList();
    tags.value = Map<String, dynamic>.from(raw['tags']).map((key, value) =>
        MapEntry<String, List<String>>(key, List<String>.from(value)));
    sources.value = List<String>.from(raw['sources']);
    parent.value = raw["relationships"]['parent_id'];
    description.value = raw['description'];
    rating.value = raw['rating'].toLowerCase();
    comments.value = raw['comment_count'];
    file.value = PostImageFile.fromMap(raw['file']);
    sample.value = PostImage.fromMap(raw['sample']);
    preview.value = PostImage.fromMap(raw['preview']);
    favorites = ValueNotifier(raw['fav_count']);
    isFavorite = ValueNotifier(raw['is_favorited']);
    score = ValueNotifier(raw['score']['total']);

    switch (file.value.ext) {
      case 'webm':
        if (Platform.isIOS) {
          file.value.url.replaceAll('webm', 'mp4');
        }
        type = ImageType.Video;
        break;
      case 'swf':
        type = ImageType.Unsupported;
        break;
      default:
        type = ImageType.Image;
        break;
    }

    prepareVideo();
  }

  Future<void> prepareVideo() async {
    if (type == ImageType.Video) {
      if (controller != null) {
        await controller.pause();
        await controller.dispose();
      }
      controller = VideoPlayerController.network(file.value.url);
      controller.setLooping(true);
      controller.addListener(() =>
          controller.value.isPlaying ? Wakelock.enable() : Wakelock.disable());
    }
  }

  Future<void> initVideo() async {
    if (type != ImageType.Video || loadedVideos.contains(this)) {
      return;
    }
    if (loadedVideos.length >= 6) {
      loadedVideos.first.removeVideo();
    }
    loadedVideos.add(this);
    await this.controller.initialize();
  }

  Future<void> removeVideo() async {
    await prepareVideo();
    loadedVideos.remove(this);
  }

  void dispose() {
    tags.dispose();
    comments.dispose();
    parent.dispose();
    score.dispose();
    favorites.dispose();
    rating.dispose();
    description.dispose();
    sources.dispose();
    isFavorite.dispose();
    isEditing.dispose();
    showUnsafe.dispose();
    controller?.dispose();
    loadedVideos.remove(this);
  }

  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/posts/$id');
}

enum ImageType {
  Image,
  Video,
  Unsupported,
}

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}
