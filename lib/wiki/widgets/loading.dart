import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class WikiLoadingPage extends StatefulWidget {
  const WikiLoadingPage(this.id, {super.key});

  final String id;

  @override
  State<WikiLoadingPage> createState() => _WikiLoadingPageState();
}

class _WikiLoadingPageState extends State<WikiLoadingPage> {
  late Future<Wiki> wiki = context.read<Client>().wikis.get(id: widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Wiki>(
      future: wiki,
      builder: (context, value) => WikiPage(wiki: value),
      title: Text('Wiki #${widget.id}'),
      onError: const Text('Failed to load wiki'),
      onEmpty: const Text('Wiki not found'),
    );
  }
}
