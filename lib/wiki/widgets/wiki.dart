import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class WikiPage extends StatelessWidget {
  final Wiki wiki;

  const WikiPage({required this.wiki});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: DefaultAppBar(
        title: Text(tagToTitle(wiki.title)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => wikiSheet(context, wiki),
          ),
        ],
      ),
      body: ListView(
        primary: true,
        padding: defaultActionListPadding
            .add(const EdgeInsets.symmetric(horizontal: 12)),
        children: [
          DText(wiki.body),
        ],
      ),
      drawer: const NavigationDrawer(),
    );
  }
}
