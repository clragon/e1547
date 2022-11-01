import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:crypto/crypto.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

extension PostDenying on Post {
  bool isDeniedBy(List<String> denylist) => getDeniers(denylist) != null;

  List<String>? getDeniers(List<String> denylist) {
    List<String> deniers = [];
    for (String line in denylist) {
      List<String> deny = [];
      List<String> any = [];
      List<String> allow = [];

      line.split(' ').where((tag) => tagToName(tag).isNotEmpty).forEach((tag) {
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
      });

      bool denied = deny.every(hasTag);
      bool allowed = allow.any(hasTag);
      bool optional = any.isEmpty || any.any(hasTag);

      if (denied && optional && !allowed) {
        deniers.add(line);
      }
    }
    if (deniers.isEmpty) {
      return null;
    }
    return deniers;
  }

  bool isIgnored() => (file.url == null && !flags.deleted) || file.ext == 'swf';
}

extension PostDownloading on Post {
  Future<void> download(AppInfo appInfo) async {
    if (!await Permission.storage.request().isGranted) {
      return;
    }
    File download = await DefaultCacheManager().getSingleFile(file.url!);
    if (Platform.isAndroid) {
      String directory = join(
        (await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_PICTURES)),
        appInfo.appName,
      );
      await Directory(directory).create();
      File target = File(join(directory, _downloadName()));
      if (!await target.exists() ||
          md5.convert(await download.readAsBytes()) !=
              md5.convert(await target.readAsBytes())) {
        await download.copy(target.path);
        await MediaScanner.loadMedia(path: directory);
      }
    } else if (Platform.isIOS) {
      await ImageGallerySaver.saveFile(download.path);
    } else {
      String directory = (await getDownloadsDirectory())!.path;
      File target = File(join(directory, _downloadName()));
      if (!await target.exists() ||
          md5.convert(await download.readAsBytes()) !=
              md5.convert(await target.readAsBytes())) {
        await download.copy(target.path);
      }
    }
  }

  String _downloadName() {
    String filename = '';
    List<String> artists = filterArtists(tags['artist']!);
    if (artists.isNotEmpty) {
      filename = '${artists.join(', ')} - ';
    }
    filename += '$id.${file.ext}';
    return filename;
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
        if (Platform.isAndroid || Platform.isIOS) {
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

  CachedVideoPlayerController? getVideo(BuildContext context) {
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
  String get link => getPostLink(id);
}

String getPostLink(int id) => '/posts/$id';
