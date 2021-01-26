import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

void wikiDialog(BuildContext context, String tag, {bool actions = false}) {
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
        actions ? TagActions(tag) : Container(),
      ],
    );
  }

  showDialog(
    context: context,
    child: AlertDialog(
      title: title(),
      content: body(),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    ),
  );
}
