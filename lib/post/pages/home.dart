import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PostProvider provider;

  void update() {
    if (provider != null) {
      db.homeTags.value = Future.value(provider.search.value);
    }
  }

  @override
  void initState() {
    super.initState();
    db.homeTags.value.then(
      (value) {
        setState(
          () {
            provider = PostProvider(
              search: value,
            );
          },
        );
        provider.search.addListener(update);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // removing this isn't necessary
    // the provider will be disposed by the child.
    // provider?.search?.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    if (provider != null) {
      return PostsPage(
          appBarBuilder: defaultAppBar('Home'), provider: provider);
    } else {
      return Scaffold(
        body: Center(
          child: Container(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
