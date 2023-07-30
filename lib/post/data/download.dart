import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart';

extension PostDownloading on Post {
  Future<void> download({
    required Settings settings,
    required AppInfo appInfo,
  }) async {
    try {
      File download = await DefaultCacheManager().getSingleFile(file.url!);
      if (Platform.isAndroid) {
        Uint8List downloadBytes = await download.readAsBytes();
        String downloadMime = await _throwOnNull(lookupMimeType(download.path),
            'Could not determine MIME of download!');
        Uri target = Uri.parse(settings.downloadPath.value);
        if (target.path == '/tree/primary${Uri.encodeComponent(':Pictures')}') {
          target = target.replace(path: '${target.path}/${appInfo.appName}');
        }
        if (!await isPersistedUri(target)) {
          target = await _throwOnNull(
            openDocumentTree(initialUri: target),
            'No SAF folder was chosen!',
          );
          settings.downloadPath.value = target.toString();
        }
        DocumentFile dir = await _throwOnNull(
            target.toDocumentFile(), 'Could not open SAF folder!');
        if (target.path == '/tree/primary${Uri.encodeComponent(':Pictures')}') {
          DocumentFile? subdir = await dir.findFile(appInfo.appName);
          if (subdir != null &&
              await _throwOnNull(
                subdir.isDirectory,
                'Could not determine App SAF directory',
              )) {
            dir = subdir;
          } else {
            dir = await _throwOnNull(
              dir.createDirectory(appInfo.appName),
              'Could not create App SAF folder!',
            );
          }
        }
        DocumentFile? file = await dir.findFile(_downloadName());
        if (file != null) {
          Digest downloadMd5 = md5.convert(downloadBytes);
          Digest fileMd5 = md5.convert(await _throwOnNull(
            file.getContent(),
            'Could not read SAF file!',
          ));
          if (downloadMd5 != fileMd5) {
            file.writeToFileAsBytes(
              bytes: downloadBytes,
            );
          }
        } else {
          file = await _throwOnNull(
            dir.createFile(
              mimeType: downloadMime,
              displayName: _downloadName(),
              bytes: downloadBytes,
            ),
            'Could not create SAF file!',
          );
        }
      } else if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(download.path);
      } else {
        String directory = (await getDownloadsDirectory())!.path;
        File target = File(join(directory, _downloadName()));
        if (!target.existsSync() ||
            md5.convert(await download.readAsBytes()) !=
                md5.convert(await target.readAsBytes())) {
          await download.copy(target.path);
        }
      }
    } on Exception catch (e) {
      throw PostDownloadException.from(e);
    }
  }

  String _downloadName() {
    String filename = '';
    List<String> artists = filterArtists(tags['artist']!);
    if (artists.isNotEmpty) {
      filename = '${artists.join(', ')} - ';
    }
    return filename += '$id.${file.ext}';
  }

  Future<T> _throwOnNull<T>(FutureOr<T?> future, String message) async {
    T? result = await future;
    if (result == null) {
      throw PostDownloadException(message);
    }
    return result;
  }
}

class PostDownloadException implements Exception {
  PostDownloadException(String this.message) : inner = null;

  PostDownloadException.from(Object this.inner) : message = null;

  final String? message;
  final Object? inner;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    }
    if (inner != null) {
      if (inner is PostDownloadException) {
        return inner.toString();
      }
      return '$runtimeType: $inner';
    }
    return '$runtimeType: unknown cause!';
  }
}
