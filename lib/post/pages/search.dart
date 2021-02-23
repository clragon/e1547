import 'package:e1547/post.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final String tags;
  SearchPage({this.tags});

  @override
  Widget build(BuildContext context) {
    PostProvider provider = PostProvider(search: tags);
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: ValueListenableBuilder(
            valueListenable: provider.search,
            builder: (context, value, child) {
              if (Tagset.parse(value).length == 1) {
                return Text(value.toString().replaceAll('_', ' '));
              } else {
                return Text('Search');
              }
            },
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            ValueListenableBuilder(
              valueListenable: provider.search,
              builder: (context, value, child) {
                if (Tagset.parse(value).length == 1) {
                  return IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () => wikiSheet(context: context, tag: value),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        );
      },
      provider: provider,
    );
  }
}
