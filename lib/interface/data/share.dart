import 'dart:io';

import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as plus;

abstract final class Share {
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
      File file = File(
        join(
          await getTemporaryDirectory().then((e) => e.path),
          name ?? '${logFileDateFormat.format(DateTime.now())}.txt',
        ),
      );
      await file.writeAsString(text);
      await plus.Share.shareXFiles([plus.XFile(file.path)]);
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
