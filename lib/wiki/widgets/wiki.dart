import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class WikiPage extends StatelessWidget {
  const WikiPage({super.key, required this.wiki});

  final Wiki wiki;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: DefaultAppBar(
        title: Text(tagToName(wiki.title)),
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
      drawer: const RouterDrawer(),
    );
  }
}
