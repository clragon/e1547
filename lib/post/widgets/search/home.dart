import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LinkingMixin {
  PostController controller = PostController(search: settings.homeTags.value);

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        controller: update,
      };

  void update() {
    settings.homeTags.value = controller.search.value;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: defaultAppBarBuilder('Home'),
      controller: controller,
    );
  }
}
