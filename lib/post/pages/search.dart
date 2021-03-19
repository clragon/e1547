import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String tags;
  SearchPage({this.tags});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  PostProvider provider;

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    provider = PostProvider(search: widget.tags);
    provider.search.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    provider.search.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: CrossFade(
            showChild: Tagset.parse(provider.search.value).length == 1,
            child: Text(provider.search.value.replaceAll('_', ' ')),
            secondChild: Text('Search'),
          ),
          leading: BackButton(),
          actions: [
            CrossFade(
              showChild: Tagset.parse(provider.search.value).length == 1,
              child: IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () =>
                    wikiSheet(context: context, tag: provider.search.value),
              ),
            ),
          ],
        );
      },
      provider: provider,
    );
  }
}
