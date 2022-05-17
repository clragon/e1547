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
    return Scaffold(
      appBar: DefaultAppBar(
        leading: const BackButton(),
        title: Text(tagToTitle(wiki.title)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => wikiSheet(context, wiki),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: defaultActionListPadding
            .add(const EdgeInsets.symmetric(horizontal: 12)),
        child: DText(wiki.body),
      ),
    );
  }
}
