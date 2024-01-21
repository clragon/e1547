import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';

typedef ClientException = DioException;

extension QueryMapExtension on Map<String, dynamic> {
  /// Transforms a given Map into a QueryMap.
  ///
  /// Null values are omitted.
  /// All other values are converted to strings.
  QueryMap toQuery() => Map.fromEntries(
        entries.where((entry) => entry.value != null).map(
              (entry) => MapEntry(
                entry.key,
                entry.value.toString(),
              ),
            ),
      );
}

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on ClientException {
    return false;
  }
}

/// Ensures that a call takes at least [duration] time to complete.
/// This allows making API calls in loops while being mindful of the server.
///
/// - [duration] defaults to 500 ms
Future<T> rateLimit<T>(Future<T> call, [Duration? duration]) => Future.wait(
        [call, Future.delayed(duration ?? const Duration(milliseconds: 500))])
    .then((value) => value[0]);

Options forceOptions(bool? force) {
  return ClientCacheConfig(
    policy: (force ?? false) ? CachePolicy.refresh : CachePolicy.request,
  ).toOptions();
}

class NoUserLoginException implements Exception {
  NoUserLoginException();

  @override
  String toString() => 'NoUserLoginException';
}

String? findFavicon(String html) {
  final headRegExp =
      RegExp(r'<head>.*?</head>', dotAll: true, caseSensitive: false);
  final linkRegExp =
      RegExp(r'<link\s+[^>]*?rel=".*?icon.*?"[^>]*?>', caseSensitive: false);
  final sizeRegExp = RegExp(r'(\d+)x\d+');

  final headMatch = headRegExp.firstMatch(html);
  if (headMatch == null) return null;

  String headContent = headMatch.group(0)!;

  final favicons = linkRegExp.allMatches(headContent);
  String? highestResFavicon;
  int highestResolution = 0;

  String? extractAttribute(String tag, String attributeName) {
    final attrRegExp = RegExp('$attributeName="([^"]+)"', caseSensitive: false);
    final match = attrRegExp.firstMatch(tag);
    return match?.group(1);
  }

  for (final match in favicons) {
    String linkTag = match.group(0)!;

    String? rel = extractAttribute(linkTag, 'rel');
    String? href = extractAttribute(linkTag, 'href');
    String? type = extractAttribute(linkTag, 'type');
    String? sizes = extractAttribute(linkTag, 'sizes');

    if (href == null) continue;
    if (type != null && type.contains('svg+xml')) continue;

    if (sizes == null) {
      if (rel == 'apple-touch-icon') {
        sizes = '120x120';
      }
    }

    if (sizes == null) {
      final sizeMatch = sizeRegExp.firstMatch(href);
      if (sizeMatch != null) {
        sizes = sizeMatch.group(0);
      }
    }

    sizes ??= '16x16'; // this ensures we match single no size favicons

    final sizeMatch = sizeRegExp.firstMatch(sizes);
    if (sizeMatch != null) {
      final resolution = int.parse(sizeMatch.group(1)!);
      if (resolution > highestResolution) {
        highestResolution = resolution;
        highestResFavicon = href;
      }
    }
  }

  return highestResFavicon;
}
