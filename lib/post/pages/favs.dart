import 'package:e1547/client.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.credentials.value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return PostsPage(
              appBarBuilder: appBarWidget('Favorites'),
              provider: PostProvider(
                provider: (tags, page) {
                  return client.posts(tags, page);
                },
                search: 'fav:${snapshot.data.username}',
                canDeny: false,
              ));
        } else {
          return Scaffold(
            appBar: appBarWidget('Favorites')(context),
            body: Center(
              child: Container(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
