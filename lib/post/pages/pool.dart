import 'package:e1547/client.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PoolPage extends StatelessWidget {
  final Pool pool;

  PoolPage({@required this.pool});

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text(pool.name.replaceAll('_', ' ')),
          leading: BackButton(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              tooltip: 'Info',
              onPressed: () => poolSheet(context, pool),
            )
          ],
        );
      },
      provider: PostProvider(
          provider: (tags, page) => client.poolPosts(pool.id, page),
          canSearch: false),
    );
  }
}
