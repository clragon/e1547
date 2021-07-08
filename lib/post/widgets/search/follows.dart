import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: db.follows,
      builder: (context, value, child) {
        return PostsPage(
          appBarBuilder: (context) {
            return AppBar(
              title: Text('Following'),
              actions: [
                IconButton(
                  icon: Icon(Icons.turned_in),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.pushNamed(context, '/following'),
                )
              ],
            );
          },
          provider: PostProvider(
            provider: (tags, page) => client.follows(page),
            canSearch: false,
          ),
        );
      },
    );
  }
}
