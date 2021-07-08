import 'dart:io';

import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'post.dart';

extension denying on Post {
  Future<bool> isDeniedBy(List<String> denylist) async =>
      await deniedBy(denylist) != null;

  Future<String> deniedBy(List<String> denylist) async {
    if (denylist.length > 0) {
      List<String> tags =
          this.tags.value.values.expand((tags) => tags).toList();

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

        bool containtsTag(String tag, List<String> tags) {
          if (tag.contains(':')) {
            String identifier = tag.split(':')[0];
            String value = tag.split(':')[1];
            switch (identifier) {
              case 'rating':
                if (this.rating.value.toLowerCase() == value.toLowerCase()) {
                  return true;
                }
                break;
              case 'id':
                if (this.id == int.tryParse(value)) {
                  return true;
                }
                break;
              case 'type':
                if (this.file.value.ext.toLowerCase() == value.toLowerCase()) {
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
                if (this.uploader.toString() == value) {
                  return true;
                }
                break;
              case 'score':
                bool greater = value.contains('>');
                bool smaller = value.contains('<');
                bool equal = value.contains('=');
                int score = int.tryParse(value.replaceAll(r'[<>=]', ''));
                if (greater) {
                  if (equal) {
                    if (this.score.value >= score) {
                      return true;
                    }
                  } else {
                    if (this.score.value > score) {
                      return true;
                    }
                  }
                }
                if (smaller) {
                  if (equal) {
                    if (this.score.value <= score) {
                      return true;
                    }
                  } else {
                    if (this.score.value < score) {
                      return true;
                    }
                  }
                }
                if ((!greater && !smaller) && this.score.value == score) {
                  return true;
                }
                break;
            }
          }

          return tags.contains(tag.toLowerCase());
        }

        bool denied = deny.every((tag) => containtsTag(tag, tags));
        bool allowed = allow.any((tag) => containtsTag(tag, tags));
        bool optional =
            any.isEmpty || any.any((tag) => containtsTag(tag, tags));

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
      File download =
          await DefaultCacheManager().getSingleFile(this.file.value.url);
      if (Platform.isAndroid) {
        String directory =
            '${Platform.environment['EXTERNAL_STORAGE']}/Pictures';
        directory = [directory, appName].join('/');
        String filename = '${artists.join(', ')} - $id.${file.value.ext}';
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
      this.isFavorite.value = false;
      this.favorites.value -= 1;
      return true;
    } else {
      this.isFavorite.value = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to remove Post #${this.id} from favorites'),
      ));
      return false;
    }
  }

  Future<bool> tryAddFav(BuildContext context) async {
    Future<void> cooldown = Future.delayed(Duration(milliseconds: 1000));
    if (await client.addFavorite(this.id)) {
      () async {
        // cooldown ensures no interference with like animation
        await cooldown;
        this.isFavorite.value = true;
      }();
      this.favorites.value += 1;
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to add Post #${this.id} to favorites'),
      ));
      return false;
    }
  }
}

extension voting on Post {
  Future<void> tryVote(
      {@required BuildContext context,
      @required bool upvote,
      @required bool replace}) async {
    if (await client.votePost(this.id, upvote, replace)) {
      if (this.voteStatus.value == VoteStatus.unknown) {
        if (upvote) {
          this.score.value += 1;
          this.voteStatus.value = VoteStatus.upvoted;
        } else {
          this.score.value -= 1;
          this.voteStatus.value = VoteStatus.downvoted;
        }
      } else {
        if (upvote) {
          if (this.voteStatus.value == VoteStatus.upvoted) {
            this.score.value -= 1;
            this.voteStatus.value = VoteStatus.unknown;
          } else {
            this.score.value += 2;
            this.voteStatus.value = VoteStatus.upvoted;
          }
        } else {
          if (this.voteStatus.value == VoteStatus.upvoted) {
            this.score.value -= 2;
            this.voteStatus.value = VoteStatus.downvoted;
          } else {
            this.score.value += 1;
            this.voteStatus.value = VoteStatus.unknown;
          }
        }
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
      reset = Post.fromMap(this.raw);
    } else {
      reset = await client.post(this.id);
      this.raw = reset.raw;
    }

    this.favorites.value = reset.favorites.value;
    this.score.value = reset.score.value;
    this.tags.value = reset.tags.value;
    this.description.value = reset.description.value;
    this.sources.value = reset.sources.value;
    this.rating.value = reset.rating.value;
    this.parent.value = reset.parent.value;
    this.isEditing.value = false;
  }
}

String getPostHero(Post post) {
  return 'image_${post.id}';
}
