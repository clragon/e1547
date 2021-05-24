import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class HotPage extends StatefulWidget {
  const HotPage();

  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  PostProvider provider = PostProvider(search: "order:rank");

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: defaultAppBar('Hot'),
      provider: provider,
    );
  }
}
