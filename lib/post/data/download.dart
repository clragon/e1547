import 'dart:async';
import 'dart:io';

import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
        throw FileDownloadException('Post does not have a file!');
      }

      File downloadFile = await cache.getSingleFile(url);

      await FileDownloader.downloadImage(
        file: downloadFile,
        directory: path,
        folderName: folder,
        fileName: _downloadName(),
        onDirectoryChanged: onPathChanged,
      );
    } on FileDownloadException {
      rethrow;
    } on Exception catch (e) {
      throw FileDownloadException.from(e);
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
}
