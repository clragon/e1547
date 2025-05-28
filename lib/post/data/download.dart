import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getDefaultDownloadPath() async =>
    switch (Platform.operatingSystem) {
      'android' => Uri(
        scheme: 'content',
        host: 'com.android.externalstorage.documents',
        path: '/tree/primary${Uri.encodeComponent(':Pictures')}',
      ).toString(),
      'ios' => null,
      _ => await getDownloadsDirectory().then((value) => value?.path),
    };

extension PostDownloading on Post {
  Future<void> download({
    required String? path,
    required void Function(String value) onPathChanged,
    required String folder,
    required BaseCacheManager cache,
  }) async {
    try {
      String? url = file;

      if (url == null) {
        throw PostDownloadException('Post does not have a file!');
      }

      File download = await cache.getSingleFile(url);

      if (Platform.isIOS) {
        await ImageGallerySaverPlus.saveFile(download.path);
      } else {
        String directory;

        // We have changed how paths are stored. These old paths break when updating.
        // This crude mechanism will clean that up. We can remove this in a future version.
        if (path?.contains('/tree/primary') ?? false) {
          path = null;
        }

        if (path != null) {
          directory = path;
        } else {
          directory = await _throwOnNull(
            FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Choose a download folder',
              initialDirectory: await getDefaultDownloadPath(),
            ),
            'No download folder was chosen.',
          );

          onPathChanged(directory);
        }

        if (basename(directory) == 'Pictures') {
          directory = join(directory, folder);
        }

        String fileName = _downloadName();
        File target = File(join(directory, fileName));

        Uint8List downloadBytes = await download.readAsBytes();
        await target.writeAsBytes(downloadBytes);

        if (Platform.isAndroid) {
          // Android devices require a media scan to show the file in the gallery.
          await MediaScanner.loadMedia(path: target.path);
        }
      }
    } on PostDownloadException {
      rethrow;
    } on Exception catch (e) {
      throw PostDownloadException.from(e);
    }
  }

  String _downloadName() {
    String filename = '';
    List<String> artists = filterArtists(tags['artist'] ?? []);
    if (artists.isNotEmpty) {
      filename = '${artists.join(', ')} - ';
    }
    return filename += '$id.$ext';
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
