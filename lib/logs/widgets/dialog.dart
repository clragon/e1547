import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LogFileDialog extends StatelessWidget {
  const LogFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log files'),
      content: SubFuture<List<File>>(
        create: () async => Directory(
                context.read<AppDatabases>().temporaryFiles)
            .list()
            .where((e) =>
                FileSystemEntity.isFileSync(e.path) && e.path.endsWith('.log'))
            .cast<File>()
            .toList(),
        builder: (context, snapshot) => SingleChildScrollView(
          child: Builder(builder: (context) {
            List<File>? files = snapshot.data;
            if (snapshot.hasError) {
              return const IconMessage(
                icon: Icon(Icons.warning_amber),
                title: Text('Failed to load log files!'),
              );
            }
            if (files == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (files.isEmpty) {
              return const IconMessage(
                icon: Icon(Icons.close),
                title: Text('No log files available!'),
              );
            }
            return Column(
              children: files
                  .map((e) => LogFileInfo.parse(e.path))
                  .sorted((a, b) => b.date.compareTo(a.date))
                  .map(
                    (file) => ListTile(
                      title: Text(
                        formatDateTime(file.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: file.type != null ? Text(file.type!) : null,
                      onTap: () async {
                        NavigatorState navigator = Navigator.of(context);
                        await navigator.maybePop();
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => LogFilePage(path: file.path),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            );
          }),
        ),
      ),
    );
  }
}
