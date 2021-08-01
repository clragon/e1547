import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowsCombinedPage extends StatefulWidget {
  @override
  _FollowsCombinedPageState createState() => _FollowsCombinedPageState();
}

class _FollowsCombinedPageState extends State<FollowsCombinedPage> {
  List<String?>? tags;

  PostController provider = PostController(
    provider: (tags, page) => client.follows(page),
    canSearch: false,
  );

  Future<void> updateTags() async {
    List<String?> update = (await settings.follows.value).tags;
    if (!listEquals(tags, update)) {
      provider.refresh();
      tags = update;
    }
  }

  @override
  void initState() {
    super.initState();
    settings.follows.addListener(updateTags);
  }

  @override
  void dispose() {
    super.dispose();
    settings.follows.removeListener(updateTags);
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text('Following'),
          actions: [
            IconButton(
              icon: Icon(Icons.view_comfy),
              tooltip: 'Split',
              onPressed: () => settings.followsSplit.value = Future.value(true),
            ),
            IconButton(
              icon: Icon(Icons.turned_in),
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/following'),
            )
          ],
        );
      },
      controller: provider,
    );
  }
}
