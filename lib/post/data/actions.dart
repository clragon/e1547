import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

extension Tagging on Post {
  bool hasTag(String tag) {
    if (tag.contains(':')) {
      String identifier = tag.split(':')[0];
      String value = tag.split(':')[1];
      switch (identifier) {
        case 'rating':
          if (rating == Rating.values.asNameMap()[value] ||
              value == ratingTexts[rating]!.toLowerCase()) {
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
  bool isDeniedBy(List<String> denylist) => getDeniers(denylist).isNotEmpty;

  List<String> getDeniers(List<String> denylist) {
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
    return deniers;
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
        List<String> artists = filterArtists(tags['artist']!);
        if (artists.isNotEmpty) {
          filename = '${artists.join(', ')} - ';
        }
        filename += '$id.${file.ext}';
        String filepath = [directory, filename].join('/');
        await Directory(directory).create();
        File target = File(filepath);

        if (!await target.exists() ||
            md5.convert(await download.readAsBytes()) !=
                md5.convert(await target.readAsBytes())) {
          await download.copy(filepath);
          MediaScanner.loadMedia(path: directory);
        }
      } else if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(download.path);
      } else {
        throw PlatformException(code: 'unsupported platform');
      }
      return true;
    } on Exception {
      return false;
    }
  }
}

extension Transitioning on Post {
  String get hero => getPostHero(id);
}

String getPostHero(int id) => 'image_$id';

extension Linking on Post {
  Uri url(String host) => getPostUri(host, id);
}

Uri getPostUri(String host, int id) =>
    Uri(scheme: 'https', host: host, path: '/posts/$id');

extension History on PostController {
  Future<void> addToHistory(BuildContext context, [Pool? pool]) async {
    await waitForFirstPage();
    if (pool != null) {
      historyController.addTag(
        pool.search,
        alias: pool.name,
        posts: itemList,
      );
    } else {
      historyController.addTag(
        search.value,
        posts: itemList,
      );
    }
  }
}
