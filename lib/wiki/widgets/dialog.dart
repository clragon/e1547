import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

void wikiDialog({required BuildContext context, required String tag}) {
  showDialog(
    context: context,
    builder: (context) {
      return WikiDialog(
        tag: tag,
      );
    },
  );
}

class WikiDialog extends StatelessWidget {
  final String tag;

  const WikiDialog({required this.tag});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                tagToTitle(tag),
                softWrap: true,
              ),
            ),
            TagListActions(tag: tag),
          ],
        ),
        content: ConstrainedBox(
          child: WikiBody(tag: tag),
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: Navigator.of(context).maybePop,
          ),
        ],
      ),
    );
  }
}
