import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart';

extension PostDownloading on Post {
  Future<void> download({
    required String path,
    required void Function(String value) onPathChanged,
    required String folder,
    required BaseCacheManager cache,
  }) async {
    try {
      File download = await DefaultCacheManager().getSingleFile(file!);
      if (Platform.isAndroid) {
        Uint8List downloadBytes = await download.readAsBytes();
        String downloadMime = await _throwOnNull(
          lookupMimeType(download.path),
          'Could not determine MIME of download!',
        );
        Uri target = Uri.parse(path);
        if (!await isPersistedUri(target)) {
          target = await _throwOnNull(
            openDocumentTree(initialUri: target),
            'No download folder was chosen!',
          );
          onPathChanged(target.path);
        }
        DocumentFile dir = await _throwOnNull(
          target.toDocumentFile(),
          'Could not open download folder!',
        );
        if (dir.name == 'Pictures' && (await dir.parentFile()) == null) {
          DocumentFile? appDir = await _getFolderChild(dir, folder);
          if (appDir != null) {
            dir = appDir;
          } else {
            dir = await _throwOnNull(
              dir.createDirectory(folder),
              'Could not create App download folder!',
            );
          }
        }
        String fileName = _downloadName();
        DocumentFile? file = await _getFolderChild(dir, fileName);
        if (file != null) {
          bool success = await _throwOnNull(
            file.writeToFileAsBytes(
              bytes: downloadBytes,
            ),
            'Could not write to existing download file!',
          );
          if (!success) {
            throw PostDownloadException(
              'Could not write to existing download file!',
            );
          }
        } else {
          file = await _throwOnNull(
            dir.createFile(
              mimeType: downloadMime,
              displayName: fileName,
              bytes: downloadBytes,
            ),
            'Could not create download file!',
          );
        }
      } else if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(download.path);
      } else {
        String directory = (await getDownloadsDirectory())!.path;
        File target = File(join(directory, _downloadName()));
        await download.copy(target.path);
      }
    } on PostDownloadException {
      rethrow;
    } on Exception catch (e) {
      throw PostDownloadException.from(e);
    }
  }

  /// This is a workaround for
  /// https://github.com/alexrintt/shared-storage/issues/144
  ///
  /// Preferably, we would use [DocumentFile.child].
  Future<DocumentFile?> _getFolderChild(
    DocumentFile folder,
    String name,
  ) async {
    DocumentFile? file = await Uri.parse(
      '${folder.uri}%2F${Uri.encodeComponent(name)}',
    ).toDocumentFile();
    if (file == null) return null;
    bool? exists = await file.exists();
    if (exists == null || exists == false) return null;
    return file;
  }

  String _downloadName() {
    String filename = '';
    List<String> artists = filterArtists(tags['artist']!);
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
