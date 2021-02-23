import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar Function(BuildContext) appbar = defaultAppBar('Home');
    return FutureBuilder(
      future: db.homeTags.value,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          PostProvider provider = PostProvider(
            search: snapshot.data,
          );
          provider.search.addListener(
              () => db.homeTags.value = Future.value(provider.search.value));
          return PostsPage(appBarBuilder: appbar, provider: provider);
        } else {
          return Scaffold(
            appBar: appbar(context),
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
