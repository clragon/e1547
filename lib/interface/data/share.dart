import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart' as plus;

class Share {
  static Future share(BuildContext context, String text) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return plus.Share.share(text);
    } else {
      return clipboard(context, text);
    }
  }

  static Future<void> shareFile(
    BuildContext context,
    String text,
    String path,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      File file = File(path);
      await file.writeAsString(text, flush: true);
      await plus.Share.shareFiles([file.path]);
      await file.delete();
    } else {
      return clipboard(context, text);
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
