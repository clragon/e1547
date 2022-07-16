import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WikiLoadingPage extends StatefulWidget {
  final String id;

  const WikiLoadingPage(this.id);

  @override
  State<WikiLoadingPage> createState() => _WikiLoadingPageState();
}

class _WikiLoadingPageState extends State<WikiLoadingPage> {
  late Future<Wiki> wiki = context.read<Client>().wiki(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Wiki>(
      future: wiki,
      builder: (context, value) => WikiPage(wiki: value),
      title: Text('Wiki #${widget.id}'),
      onError: const Text('Failed to load wiki'),
      onEmpty: const Text('Wiki not found'),
    );
  }
}
