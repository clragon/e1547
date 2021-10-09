import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

void wikiDialog({required BuildContext context, required String tag}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
    Widget body() {
      return ConstrainedBox(
        child: WikiBody(tag: tag),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
      );
    }

    Widget title() {
      return Row(
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
      );
    }

    return AlertDialog(
      title: title(),
      content: body(),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: Navigator.of(context).maybePop,
        ),
      ],
    );
  }
}
