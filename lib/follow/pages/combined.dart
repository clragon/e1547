import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowsCombinedPage extends StatefulWidget {
  @override
  _FollowsCombinedPageState createState() => _FollowsCombinedPageState();
}

class _FollowsCombinedPageState extends State<FollowsCombinedPage> {
  PostProvider provider = PostProvider(
    provider: (tags, page) => client.follows(page),
    canSearch: false,
  );

  Future<void> update() async {
    provider.resetPages();
  }

  @override
  void initState() {
    super.initState();
    db.follows.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text('Following'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.view_comfy),
              tooltip: 'Split',
              onPressed: () => db.followsSplit.value = Future.value(true),
            ),
            IconButton(
              icon: Icon(Icons.turned_in),
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/following'),
            )
          ],
        );
      },
      provider: provider,
    );
  }
}
