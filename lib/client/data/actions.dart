import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class NoUserLoginException implements Exception {
  NoUserLoginException();

  @override
  String toString() => 'NoUserLoginException';
}

Future<void> guardWithLogin({
  required BuildContext context,
  required VoidCallback callback,
  String? error,
}) async {
  if (context.read<Client>().hasLogin) {
    callback();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(error ?? 'You must be logged in to perform this action.'),
        action: SnackBarAction(
          label: 'Choose identity',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const IdentitiesPage(),
            ),
          ),
        ),
      ),
    );
  }
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
