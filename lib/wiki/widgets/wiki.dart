import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

import 'actions.dart';
import 'body.dart';

class WikiPage extends StatelessWidget {
  final String tag;
  final bool actions;

  const WikiPage({required this.tag, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Flexible(
          child: Text(
            tagToTitle(tag),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: actions ? [TagListActions(tag: tag)] : null,
      ),
      body: WikiBody(tag: tag),
    );
  }
}
