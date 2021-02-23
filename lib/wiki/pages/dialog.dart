import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

void wikiDialog({@required BuildContext context, @required String tag}) {
  showDialog(
    context: context,
    child: WikiDialog(
      tag: tag,
    ),
  );
}

class WikiDialog extends StatelessWidget {
  final String tag;

  WikiDialog({@required this.tag});

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return ConstrainedBox(
          child: WikiBody(tag: tag),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ));
    }

    Widget title() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              tag.replaceAll('_', ' '),
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
        FlatButton(
          child: Text('OK'),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
}
