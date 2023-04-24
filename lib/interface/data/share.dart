import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as plus;

class Share {
  static Future<void> share(BuildContext context, String text) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return plus.Share.share(text);
    } else {
      return clipboard(context, text);
    }
  }

  static Future<void> shareAsFile(
    BuildContext context,
    String text, {
    String? name,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      plus.XFile file = plus.XFile.fromData(
        Uint8List.fromList(utf8.encode(text)),
        name: name,
        mimeType: 'text/plain',
      );
      await plus.Share.shareXFiles([file]);
    } else {
      return clipboard(context, text);
    }
  }

  static Future<void> shareFile(BuildContext context, String path) async {
    plus.XFile file = plus.XFile(path);
    if (Platform.isAndroid || Platform.isIOS) {
      await plus.Share.shareXFiles([file]);
    } else {
      return clipboard(context, await file.readAsString());
    }
  }

  static Future<void> clipboard(BuildContext context, String text) async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: text),
    );
    messenger.showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Copied to clipboard'),
      ),
    );
  }
}
