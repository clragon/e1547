import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'post.dart';

extension Tagging on Post {
  bool hasTag(String tag) {
    if (tag.contains(':')) {
      String identifier = tag.split(':')[0];
      String value = tag.split(':')[1];
      switch (identifier) {
        case 'rating':
          if (rating == ratingValues.map[value]) {
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
          bool greater = value.contains('>');
          bool smaller = value.contains('<');
          bool equal = value.contains('=');
          int? score = int.tryParse(value.replaceAll(RegExp(r'[<>=]'), ''));
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

extension Denying on Post {
  bool isDeniedBy(List<String> denylist) => getDenier(denylist) != null;

  String? getDenier(List<String> denylist) {
    if (denylist.isNotEmpty) {
      for (String line in denylist) {
        List<String> deny = [];
        List<String> any = [];
        List<String> allow = [];

        line
            .split(' ')
            .where(
              (tag) => tagToName(tag).trim().isNotEmpty,
            )
            .forEach((tag) {
          String prefix = tag[0];

          switch (prefix) {
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
        });

        bool denied = deny.every((tag) => hasTag(tag));
        bool allowed = allow.any((tag) => hasTag(tag));
        bool optional = any.isEmpty || any.any((tag) => hasTag(tag));

        if (denied && optional && !allowed) {
          return line;
        }
      }
    }
    return null;
  }
}

extension Downloading on Post {
  Future<bool> download() async {
    try {
      if (!await Permission.storage.request().isGranted) {
        return false;
      }
      File download = await DefaultCacheManager().getSingleFile(file.url!);
      if (Platform.isAndroid) {
        String directory =
            '${Platform.environment['EXTERNAL_STORAGE']}/Pictures';
        directory = [directory, appInfo.appName].join('/');
        String filename = '';
        if (artists.isNotEmpty) {
          filename = '${artists.join(', ')} - ';
        }
        filename += '$id.${file.ext}';
        String filepath = [directory, filename].join('/');
        await Directory(directory).create();
        File target = File(filepath);
        if (!await target.exists()) {
          await download.copy(filepath);
        }
      } else if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(download.path);
      } else {
        throw PlatformException(code: 'unsupported platform');
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

extension Favoriting on Post {
  Future<bool> tryRemoveFav(BuildContext context) async {
    if (await client.removeFavorite(id)) {
      isFavorited = false;
      favCount -= 1;
      notifyListeners();
      return true;
    } else {
      favCount += 1;
      isFavorited = true;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to remove Post #$id from favorites'),
        ),
      );
      return false;
    }
  }

  Future<bool> tryAddFav(BuildContext context, {Duration? cooldown}) async {
    cooldown ??= Duration(milliseconds: 0);
    if (await client.addFavorite(id)) {
      // cooldown avoids interference with animation
      await Future.delayed(cooldown);
      isFavorited = true;
      favCount += 1;
      notifyListeners();
      if (settings.upvoteFavs.value) {
        Future.delayed(Duration(seconds: 1) - cooldown).then(
          (_) => tryVote(context: context, upvote: true, replace: true),
        );
      }
      return true;
    } else {
      favCount -= 1;
      isFavorited = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to add Post #$id to favorites'),
        ),
      );
      return false;
    }
  }
}

extension Voting on Post {
  Future<void> tryVote(
      {required BuildContext context,
      required bool upvote,
      required bool replace}) async {
    if (await client.votePost(id, upvote, replace)) {
      if (voteStatus == VoteStatus.unknown) {
        if (upvote) {
          score.total += 1;
          score.up += 1;
          voteStatus = VoteStatus.upvoted;
        } else {
          score.total -= 1;
          score.down += 1;
          voteStatus = VoteStatus.downvoted;
        }
      } else {
        if (upvote) {
          if (voteStatus == VoteStatus.upvoted) {
            score.total -= 1;
            score.down += 1;
            voteStatus = VoteStatus.unknown;
          } else {
            score.total += 2;
            score.up += 1;
            score.down -= 1;
            voteStatus = VoteStatus.upvoted;
          }
        } else {
          if (voteStatus == VoteStatus.upvoted) {
            score.total -= 2;
            score.up -= 1;
            score.down *= 1;
            voteStatus = VoteStatus.downvoted;
          } else {
            score.total += 1;
            score.up += 1;
            voteStatus = VoteStatus.unknown;
          }
        }
      }
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to vote on Post #$id'),
      ));
    }
  }
}

extension Editing on Post {
  Future<void> resetPost({bool online = false}) async {
    Post reset;
    if (online) {
      reset = await client.post(id);
      raw = reset.raw;
    } else {
      reset = Post.fromMap(raw);
    }

    isFavorited = reset.isFavorited;
    favCount = reset.favCount;
    score = reset.score;
    tags = reset.tags;
    description = reset.description;
    sources = reset.sources;
    rating = reset.rating;
    relationships.parentId = reset.relationships.parentId;
    isEditing = false;
    notifyListeners();
  }
}

extension Transitioning on Post {
  String get hero => getPostHero(id);
}

extension Linking on Post {
  Uri get url => getPostUri(id);
}

Uri getPostUri(int postId) =>
    Uri(scheme: 'https', host: settings.host.value, path: '/posts/$postId');

String getPostHero(int? postId) => 'image_$postId';
