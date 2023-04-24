import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogSelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const LogSelectionAppBar({
    required this.child,
  });

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<LogRecord>(
      child: child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(data.selections.first.message, maxLines: 1)
          : Text('${data.selections.length} logs'),
      actionBuilder: (context, data) => [
        IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: data.selections.map((e) => e.toFullString()).join('\n'),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Copied to clipboard'),
              ),
            );
            data.onChanged({});
          },
        ),
      ],
    );
  }
}
