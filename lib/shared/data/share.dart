import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract final class Share {
  static Future<void> text(BuildContext context, String text) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(text: text));
    } else {
      await clipboard(context, text);
    }
  }

  static Future<void> asFile(
    BuildContext context,
    String text,
    String name,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      File file = File(
        join(await getTemporaryDirectory().then((e) => e.path), name),
      );
      await file.writeAsString(text);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } else {
      final messenger = ScaffoldMessenger.of(context);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file',
        fileName: name,
      );
      if (outputFile == null) return;

      await File(outputFile).writeAsString(text);
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('File saved as ${basename(outputFile)}'),
        ),
      );
    }
  }

  static Future<void> file(BuildContext context, String path) async {
    XFile file = XFile(path);
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(files: [file]));
    } else {
      final messenger = ScaffoldMessenger.of(context);
      String content = await file.readAsString();
      if (!context.mounted) return;

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file',
        fileName: basename(path),
      );
      if (outputFile == null) return;

      await File(outputFile).writeAsString(content);
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('File saved as ${basename(outputFile)}'),
        ),
      );
    }
  }

  static Future<void> clipboard(BuildContext context, String text) async {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Copied to clipboard'),
      ),
    );
  }
}
