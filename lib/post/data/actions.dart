import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

extension PostTagging on Post {
  bool hasTag(String tag) {
    if (tag.trim().isEmpty) return false;

    if (tag.contains(':')) {
      String identifier = tag.split(':')[0];
      String value = tag.split(':')[1];
      switch (identifier) {
        case 'id':
          return id == int.tryParse(value);
        case 'rating':
          return rating == Rating.values.asNameMap()[value] ||
              value == rating.title.toLowerCase();
        case 'type':
          return ext.toLowerCase() == value.toLowerCase();
        case 'width':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(width);
        case 'height':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(height);
        case 'filesize':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(size);
        case 'score':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(vote.score);
        case 'favcount':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(favCount);
        case 'fav':
          return isFavorited;
        case 'uploader':
        case 'user':
          // This cannot be implemented, as it requires a user lookup
          return false;
        case 'userid':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(uploaderId);
        case 'username':
          // This cannot be implemented, as it requires a user lookup
          return false;
        case 'pool':
          return pools.contains(int.tryParse(value));
        case 'tagcount':
          NumberRange? range = NumberRange.tryParse(value);
          if (range == null) return false;
          return range.has(tags.values.fold<int>(
            0,
            (previousValue, element) => previousValue + element.length,
          ));
      }
    }

    return tags.values.any((category) => category.contains(tag.toLowerCase()));
  }
}

extension PostDenying on Post {
  bool isDeniedBy(List<String> denylist) => getDeniers(denylist) != null;

  List<String>? getDeniers(List<String> denylist) {
    List<String> deniers = [];

    for (String line in denylist) {
      bool pass = true;
      bool isOptional = false;
      bool hasOptional = false;

      for (String tag in line.split(' ')) {
        if (tagToRaw(tag).isEmpty) continue;

        bool optional = false;
        bool inverted = false;

        if (tag[0] == '~') {
          optional = true;
          tag = tag.substring(1);
        }

        if (tag[0] == '-') {
          inverted = true;
          tag = tag.substring(1);
        }

        bool matches = hasTag(tag);

        if (inverted) {
          matches = !matches;
        }

        if (optional) {
          isOptional = true;
          if (matches) {
            hasOptional = true;
          }
        } else {
          if (!matches) {
            pass = false;
            break;
          }
        }
      }

      if (pass && isOptional) {
        pass = hasOptional;
      }

      if (!pass) continue;

      deniers.add(line);
    }

    return deniers.isEmpty ? null : deniers;
  }
}

enum PostType {
  image,
  video,
  unsupported,
}

extension PostTyping on Post {
  PostType get type {
    switch (ext) {
      case 'mp4':
      case 'webm':
        if (PlatformCapabilities.hasVideos) {
          return PostType.video;
        }
        return PostType.unsupported;
      case 'swf':
        return PostType.unsupported;
      default:
        return PostType.image;
    }
  }
}

extension PostVideoPlaying on Post {
  VideoPlayer? getVideo(BuildContext context, {bool? listen}) {
    if (type == PostType.video && file != null) {
      VideoService service;
      if (listen ?? true) {
        service = context.watch<VideoService>();
      } else {
        service = context.read<VideoService>();
      }
      return service.getVideo(file!);
    }
    return null;
  }
}

extension PostLinking on Post {
  static String getPostLink(int id) => '/posts/$id';

  String get link => getPostLink(id);
}

mixin PostsActionController<KeyType> on ClientDataController<KeyType, Post> {
  Post? postById(int id) {
    int index = rawItems?.indexWhere((e) => e.id == id) ?? -1;
    if (index == -1) {
      return null;
    }
    return rawItems![index];
  }

  void replacePost(Post post) => updateItem(
        rawItems?.indexWhere((e) => e.id == post.id) ?? -1,
        post,
      );

  Future<bool> fav(Post post) async {
    assertOwnsItem(post);
    replacePost(
      post.copyWith(
        isFavorited: true,
        favCount: post.favCount + 1,
      ),
    );
    try {
      await client.addFavorite(post.id);
      evictCache();
      return true;
    } on ClientException {
      replacePost(
        post.copyWith(
          isFavorited: false,
          favCount: post.favCount - 1,
        ),
      );
      return false;
    }
  }

  Future<bool> unfav(Post post) async {
    assertOwnsItem(post);
    replacePost(
      post.copyWith(
        isFavorited: false,
        favCount: post.favCount - 1,
      ),
    );
    try {
      await client.removeFavorite(post.id);
      evictCache();
      return true;
    } on ClientException {
      replacePost(
        post.copyWith(
          isFavorited: true,
          favCount: post.favCount + 1,
        ),
      );
      return false;
    }
  }

  Future<bool> vote({
    required Post post,
    required bool upvote,
    required bool replace,
  }) async {
    assertOwnsItem(post);
    post = post.copyWith(
        vote: post.vote.withVote(
      upvote ? VoteStatus.upvoted : VoteStatus.downvoted,
      replace,
    ));
    replacePost(post);
    try {
      await client.votePost(post.id, upvote, replace);
      evictCache();
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<void> resetPost(Post post) async {
    assertOwnsItem(post);
    replacePost(await client.post(post.id, force: true));
    evictCache();
  }

  // TODO: create a PostUpdate Object instead of a Map
  Future<void> updatePost(Post post, Map<String, String?> body) async {
    assertOwnsItem(post);
    await client.updatePost(post.id, body);
    await resetPost(post);
  }
}
