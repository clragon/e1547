import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with ListenerCallbackMixin, DrawerEntry {
  PostController controller = PostController(search: settings.homeTags.value);

  @override
  Map<ChangeNotifier, VoidCallback> get listeners => {
        controller: update,
      };

  void update() {
    settings.homeTags.value = controller.search.value;
    controller.addToHistory(context);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBar: const DefaultAppBar(
        title: Text('Home'),
        actions: [SizedBox.shrink()],
      ),
      controller: controller,
    );
  }
}
