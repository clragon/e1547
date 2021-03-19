import 'dart:io';

import 'package:copy_to_gallery/copy_to_gallery.dart';
import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:permission_handler/permission_handler.dart';

import 'post.dart';

extension denying on Post {
  Future<bool> isDeniedBy(List<String> denylist) async =>
      await deniedBy(denylist) != null;

  Future<String> deniedBy(List<String> denylist) async {
    if (denylist.length > 0) {
      List<String> tags = [];
      this.tags.value.forEach((k, v) {
        tags.addAll(v.cast<String>());
      });

      for (String line in denylist) {
        List<String> deny = [];
        List<String> allow = [];
        line.split(' ').forEach((tag) {
          if (tag.isNotEmpty) {
            if (tag[0] == '-') {
              allow.add(tag.substring(1));
            } else {
              deny.add(tag);
            }
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
                if (this.file.value.ext == value) {
                  return true;
                }
                break;
              case 'pool':
                if (this.pools.contains(value)) {
                  return true;
                }
                break;
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

          if (tags.contains(tag)) {
            return true;
          } else {
            return false;
          }
        }

        bool denied = true;
        bool allowed = true;

        for (String tag in deny) {
          if (!containtsTag(tag, tags)) {
            denied = false;
            break;
          }
        }
        for (String tag in allow) {
          if (!containtsTag(tag, tags)) {
            allowed = false;
            break;
          }
        }

        if (deny.isNotEmpty && allow.isNotEmpty) {
          if (denied) {
            if (!allowed) {
              return line;
            }
          }
        } else {
          if (deny.isNotEmpty) {
            if (denied) {
              return line;
            }
          } else {
            if (!allowed) {
              return line;
            }
          }
        }
      }
    }
    return null;
  }
}

extension downloading on Post {
  Future<bool> download() async {
    if (!await Permission.storage.request().isGranted) {
      return false;
    }
    String filename =
        '${this.artists.join(', ')} - ${this.id}.${this.file.value.ext}';
    File file = await DefaultCacheManager().getSingleFile(this.file.value.url);
    try {
      await CopyToGallery.copyNamedPictures(appName, {file.path: filename});
      return true;
    } catch (Exception) {
      return false;
    }
  }

  Future<bool> downloadDialog(BuildContext context) async {
    bool success = false;
    if (!await Permission.storage.request().isGranted) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                  'You need to grant write permission in order to download files.'),
              actions: [
                ElevatedButton(
                  child: Text('TRY AGAIN'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    success =
                        await downloadDialog(context); // recursively re-execute
                  },
                ),
              ],
            );
          });
      return success;
    }

    return await this.download();
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
