import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

class WikiPage extends StatelessWidget {
  final String tag;
  final bool actions;

  const WikiPage(this.tag, this.actions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            tag.replaceAll('_', ' '),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          actions ? TagActions(tag) : Container(),
        ],
      ),
      body: WikiBody(tag: tag),
    );
  }
}
