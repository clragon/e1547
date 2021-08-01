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
  PostController? controller;

  void update() {
    settings.homeTags.value = Future.value(controller!.search.value);
  }

  @override
  void initState() {
    super.initState();
    settings.homeTags.value.then(
      (value) {
        setState(() {
          controller = PostController(search: value);
        });
        controller!.search.addListener(update);
      },
    );
  }

  @override
  void dispose() {
    controller?.search.removeListener(update);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLoader(
      isBuilt: controller != null,
      builder: (context) => PostsPage(
        appBarBuilder: defaultAppBar('Home'),
        controller: controller!,
      ),
    );
  }
}
