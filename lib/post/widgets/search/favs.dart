import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  bool error = false;
  PostProvider? provider;

  @override
  void initState() {
    super.initState();
    db.credentials.value.then((value) {
      if (value != null) {
        setState(() {
          provider = PostProvider(
            provider: (tags, page) {
              return client.posts(tags, page);
            },
            search: 'fav:${value.username}',
            canDeny: false,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLoader(
      builder: (context) => PostsPage(
        appBarBuilder: defaultAppBar('Favorites'),
        provider: provider!,
      ),
      isBuilt: provider != null,
      isLoading: false,
      isEmpty: false,
      isError: error,
      onError: Text('User is not logged in'),
    );
  }
}
