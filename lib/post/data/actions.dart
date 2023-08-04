import 'dart:async';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

extension PostTagging on Post {
  bool hasTag(String tag) {
    if (tag.contains(':')) {
      String identifier = tag.split(':')[0];
      String value = tag.split(':')[1];
      switch (identifier) {
        case 'rating':
          if (rating == Rating.values.asNameMap()[value] ||
              value == rating.title.toLowerCase()) {
            return true;
          }
          break;
        case 'id':
          if (id == int.tryParse(value)) {
            return true;
          }
          break;
        case 'type':
          if (file.ext.toLowerCase() == value.toLowerCase()) {
            return true;
          }
          break;
        case 'pool':
          if (pools.contains(int.tryParse(value))) {
            return true;
          }
          break;
        case 'uploader':
        case 'userid':
        case 'user':
          if (uploaderId.toString() == value) {
            return true;
          }
          break;
        case 'score':
          RegExpMatch? match = RegExp(
            r'^(?<direction>[<>])?(?<equals>=)?(?<score>d+)\$',
          ).firstMatch(value);
          if (match == null) return false;
          bool greater = match.namedGroup('direction') == '>';
          bool smaller = match.namedGroup('direction') == '<';
          bool equal = match.namedGroup('equals') == '=';
          int? score = int.tryParse(match.namedGroup('score')!);
          if (score != null) {
            if (greater) {
              if (equal) {
                if (this.score.total >= score) {
                  return true;
                }
              } else {
                if (this.score.total > score) {
                  return true;
                }
              }
            }
            if (smaller) {
              if (equal) {
                if (this.score.total <= score) {
                  return true;
                }
              } else {
                if (this.score.total < score) {
                  return true;
                }
              }
            }
            if ((!greater && !smaller) && this.score.total == score) {
              return true;
            }
          }
          break;
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
      List<String> deny = [];
      List<String> any = [];
      List<String> allow = [];

      for (final tag in line.split(' ')) {
        if (tagToRaw(tag).isEmpty) continue;

        switch (tag[0]) {
          case '-':
            allow.add(tag.substring(1));
            break;
          case '~':
            any.add(tag.substring(1));
            break;
          default:
            deny.add(tag);
            break;
        }
      }

      bool denied = deny.every(hasTag);
      if (!denied) continue;

      bool allowed = allow.any(hasTag);
      if (allowed) continue;

      bool optional = any.isEmpty || any.any(hasTag);
      if (!optional) continue;

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
    switch (file.ext) {
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
  VideoConfig? get videoConfig => type == PostType.video && file.url != null
      ? VideoConfig(
          url: file.url!,
          size: file.size,
        )
      : null;

  VideoPlayerController? getVideo(BuildContext context) {
    if (videoConfig != null) {
      return VideoHandler.of(context).getVideo(videoConfig!);
    }
    return null;
  }

  Future<void> loadVideo(BuildContext context) async {
    if (videoConfig != null) {
      await VideoHandler.of(context).loadVideo(videoConfig!);
    }
  }

  Future<void> disposeVideo(BuildContext context) async {
    if (videoConfig != null) {
      await VideoHandler.of(context).disposeVideo(videoConfig!);
    }
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
    if (post.voteStatus == VoteStatus.unknown) {
      if (upvote) {
        post = post.copyWith(
          score: post.score.copyWith(
            total: post.score.total + 1,
            up: post.score.up + 1,
          ),
          voteStatus: VoteStatus.upvoted,
        );
      } else {
        post = post.copyWith(
          score: post.score.copyWith(
            total: post.score.total - 1,
            down: post.score.down + 1,
          ),
          voteStatus: VoteStatus.downvoted,
        );
      }
    } else {
      if (upvote) {
        if (post.voteStatus == VoteStatus.upvoted) {
          post = post.copyWith(
            score: post.score.copyWith(
              total: post.score.total - 1,
              down: post.score.down + 1,
            ),
            voteStatus: VoteStatus.unknown,
          );
        } else {
          post = post.copyWith(
            score: post.score.copyWith(
              total: post.score.total + 2,
              up: post.score.up + 1,
              down: post.score.down - 1,
            ),
            voteStatus: VoteStatus.upvoted,
          );
        }
      } else {
        if (post.voteStatus == VoteStatus.upvoted) {
          post = post.copyWith(
            score: post.score.copyWith(
              total: post.score.total - 2,
              up: post.score.up - 1,
              down: post.score.down + 1,
            ),
            voteStatus: VoteStatus.downvoted,
          );
        } else {
          post = post.copyWith(
            score: post.score.copyWith(
              total: post.score.total + 1,
              up: post.score.up + 1,
            ),
            voteStatus: VoteStatus.unknown,
          );
        }
      }
    }
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
