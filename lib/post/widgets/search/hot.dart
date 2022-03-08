import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class HotPage extends StatefulWidget {
  const HotPage();

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with ListenerCallbackMixin {
  PostController controller = PostController(search: "order:rank");

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        controller.search: () => controller.addToHistory(context),
      };

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) => DefaultAppBar(
        title: Text('Hot'),
        actions: [SizedBox.shrink()],
      ),
      controller: controller,
    );
  }
}
