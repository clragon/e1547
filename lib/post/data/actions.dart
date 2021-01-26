import 'dart:io';

import 'package:copy_to_gallery/copy_to_gallery.dart';
import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager;
import 'package:permission_handler/permission_handler.dart';

import 'post.dart';

Future<bool> download(Post post) async {
  String filename =
      '${post.artists.join(', ')} - ${post.id}.${post.file.value.ext}';
  File file = await DefaultCacheManager().getSingleFile(post.file.value.url);
  try {
    await CopyToGallery.copyNamedPictures(appName, {file.path: filename});
    return true;
  } catch (Exception) {
    return false;
  }
}

Future<bool> downloadDialog(BuildContext context, Post post) async {
  bool success = false;
  if (!await Permission.storage.request().isGranted) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'You need to grant write permission in order to download files.'),
            actions: [
              RaisedButton(
                child: Text('TRY AGAIN'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  success = await downloadDialog(
                      context, post); // recursively re-execute
                },
              ),
            ],
          );
        });
    return success;
  }

  return await download(post);
}

Future<bool> tryRemoveFav(BuildContext context, Post post) async {
  if (await client.removeFavorite(post.id)) {
    post.isFavorite.value = false;
    post.favorites.value -= 1;
    return true;
  } else {
    post.isFavorite.value = true;
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to remove Post #${post.id} from favorites'),
    ));
    return false;
  }
}

Future<bool> tryAddFav(BuildContext context, Post post) async {
  Future<void> cooldown = Future.delayed(const Duration(milliseconds: 1000));
  if (await client.addFavorite(post.id)) {
    () async {
      // cooldown ensures no interference with like animation
      await cooldown;
      post.isFavorite.value = true;
    }();
    post.favorites.value += 1;
    return true;
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to add Post #${post.id} to favorites'),
    ));
    return false;
  }
}

Future<void> tryVote(
    BuildContext context, Post post, bool upvote, bool replace) async {
  if (await client.votePost(post.id, upvote, replace)) {
    if (post.voteStatus.value == VoteStatus.unknown) {
      if (upvote) {
        post.score.value += 1;
        post.voteStatus.value = VoteStatus.upvoted;
      } else {
        post.score.value -= 1;
        post.voteStatus.value = VoteStatus.downvoted;
      }
    } else {
      if (upvote) {
        if (post.voteStatus.value == VoteStatus.upvoted) {
          post.score.value -= 1;
          post.voteStatus.value = VoteStatus.unknown;
        } else {
          post.score.value += 2;
          post.voteStatus.value = VoteStatus.upvoted;
        }
      } else {
        if (post.voteStatus.value == VoteStatus.upvoted) {
          post.score.value -= 2;
          post.voteStatus.value = VoteStatus.downvoted;
        } else {
          post.score.value += 1;
          post.voteStatus.value = VoteStatus.unknown;
        }
      }
    }
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Failed to vote on Post #${post.id}'),
    ));
  }
}

Future<void> resetPost(Post post, {bool online = false}) async {
  Post reset;
  if (!online) {
    reset = Post.fromMap(post.raw);
  } else {
    reset = await client.post(post.id);
    post.raw = reset.raw;
  }

  post.favorites.value = reset.favorites.value;
  post.score.value = reset.score.value;
  post.tags.value = reset.tags.value;
  post.description.value = reset.description.value;
  post.sources.value = reset.sources.value;
  post.rating.value = reset.rating.value;
  post.parent.value = reset.parent.value;
  post.isEditing.value = false;
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'general':
      return Colors.indigo[300];
    case 'species':
      return Colors.teal[300];
    case 'character':
      return Colors.lightGreen[300];
    case 'copyright':
      return Colors.yellow[300];
    case 'meta':
      return Colors.deepOrange[300];
    case 'lore':
      return Colors.pink[300];
    case 'artist':
      return Colors.deepPurple[300];
    default:
      return Colors.grey[300];
  }
}

Map<String, int> categories = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'meta': 7,
  'lore': 8,
  'artist': 1,
  'invalid': 6,
};
