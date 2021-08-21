import 'dart:io';

import 'package:e1547/client/client.dart';
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

extension tagging on Post {
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
          if (this.id == int.tryParse(value)) {
            return true;
          }
          break;
        case 'type':
          if (file.ext.toLowerCase() == value.toLowerCase()) {
            return true;
          }
          break;
        case 'pool':
          if (this.pools.contains(value)) {
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
          int? score = int.tryParse(value.replaceAll(r'[<>=]', ''));
          if (greater) {
            if (equal) {
              if (this.score.total >= score!) {
                return true;
              }
            } else {
              if (this.score.total > score!) {
                return true;
              }
            }
          }
          if (smaller) {
            if (equal) {
              if (this.score.total <= score!) {
                return true;
              }
            } else {
              if (this.score.total < score!) {
                return true;
              }
            }
          }
          if ((!greater && !smaller) && this.score.total == score) {
            return true;
          }
          break;
      }
    }

    return tagMap.values
        .any((category) => category.contains(tag.toLowerCase()));
  }
}

extension denying on Post {
  Future<bool> isDeniedBy(List<String> denylist) async =>
      await getDenier(denylist) != null;

  Future<String?> getDenier(List<String> denylist) async {
    if (denylist.length > 0) {
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

extension downloading on Post {
  Future<bool> download() async {
    try {
      if (!await Permission.storage.request().isGranted) {
        return false;
      }
      File download = await DefaultCacheManager().getSingleFile(file.url!);
      if (Platform.isAndroid) {
        String directory =
            '${Platform.environment['EXTERNAL_STORAGE']}/Pictures';
        directory = [directory, appName].join('/');
        String filename = '${artists.join(', ')} - $id.${file.ext}';
        String filepath = [directory, filename].join('/');
        await Directory(directory).create();
        await download.copy(filepath);
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

extension favoriting on Post {
  Future<bool> tryRemoveFav(BuildContext context) async {
    if (await client.removeFavorite(this.id)) {
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
          content: Text('Failed to remove Post #${this.id} from favorites'),
        ),
      );
      return false;
    }
  }

  Future<bool> tryAddFav(BuildContext context, {Duration? cooldown}) async {
    if (await client.addFavorite(this.id)) {
      // cooldown avoids interference with animation
      await Future.delayed(cooldown ?? Duration(milliseconds: 0));
      isFavorited = true;
      favCount += 1;
      notifyListeners();
      return true;
    } else {
      favCount -= 1;
      isFavorited = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to add Post #${this.id} to favorites'),
        ),
      );
      return false;
    }
  }
}

extension voting on Post {
  Future<void> tryVote(
      {required BuildContext context,
      required bool upvote,
      required bool replace}) async {
    if (await client.votePost(this.id, upvote, replace)) {
      if (this.voteStatus == VoteStatus.unknown) {
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
          if (this.voteStatus == VoteStatus.upvoted) {
            score.total -= 1;
            score.down += 1;
            voteStatus = VoteStatus.unknown;
          } else {
            this.score.total += 2;
            score.up += 1;
            score.down -= 1;
            this.voteStatus = VoteStatus.upvoted;
          }
        } else {
          if (this.voteStatus == VoteStatus.upvoted) {
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
        notifyListeners();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to vote on Post #${this.id}'),
      ));
    }
  }
}

extension editing on Post {
  Future<void> resetPost({bool online = false}) async {
    Post reset;
    if (!online) {
      reset = Post.fromMap(this.json);
    } else {
      reset = await client.post(this.id);
      this.json = reset.json;
    }

    this.isFavorited = reset.isFavorited;
    this.favCount = reset.favCount;
    this.score = reset.score;
    this.tags = reset.tags;
    this.description = reset.description;
    this.sources = reset.sources;
    this.rating = reset.rating;
    this.relationships.parentId = reset.relationships.parentId;
    this.isEditing = false;
    notifyListeners();
  }
}

extension transitioning on Post {
  String get hero => 'image_$id';
}

extension linking on Post {
  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/posts/$id');
}
