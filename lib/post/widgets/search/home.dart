import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PostProvider? provider;

  void update() {
    if (provider != null) {
      db.homeTags.value = Future.value(provider!.search.value);
    }
  }

  @override
  void initState() {
    super.initState();
    db.homeTags.value.then(
      (value) {
        setState(() {
          provider = PostProvider(search: value);
        });
        provider!.search.addListener(update);
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
    return PageLoader(
      builder: (context) => PostsPage(
        appBarBuilder: defaultAppBar('Home'),
        provider: provider!,
      ),
      isBuilt: provider != null,
      isLoading: false,
      isEmpty: false,
      isError: false,
    );
  }
}
