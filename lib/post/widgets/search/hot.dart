import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class HotPage extends StatefulWidget {
  const HotPage();

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  PostController controller = PostController(search: "order:rank");

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: defaultAppBarBuilder('Hot'),
      controller: controller,
    );
  }
}
