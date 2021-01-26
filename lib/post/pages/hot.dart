import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class HotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: appBarWidget('Hot'),
      provider: PostProvider(search: "order:rank"),
    );
  }
}
