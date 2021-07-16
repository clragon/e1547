import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

  VideoPlayerController controller;

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

    if (file.value.ext == 'webm') {
      if (Platform.isIOS) {
        file.value.ext = 'mp4';
        file.value.url = file.value.url.replaceAll('.webm', '.mp4');
      }
    }
  }
}

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}
