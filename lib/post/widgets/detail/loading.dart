import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostLoadingPage extends StatefulWidget {
  final int id;

  const PostLoadingPage(this.id);

  @override
  _PostLoadingPageState createState() => _PostLoadingPageState();
}

class _PostLoadingPageState extends State<PostLoadingPage> {
  late PostController controller = singlePostController(widget.id);
  late Future<void> firstPage = controller.loadFirstPage();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<void>(
      future: firstPage,
      builder: (context, value) => PostDetailGallery(controller: controller),
      title: Text('Post #${widget.id}'),
      onError: Text('Failed to load post'),
      onEmpty: Text('Post not found'),
    );
  }
}

PostController singlePostController(int id) {
  late PostController controller;
  controller = PostController(
    provider: (search, page, force) async => page == controller.firstPageKey
        ? [await client.post(id, force: force)]
        : [],
    canSearch: false,
    denyMode: DenyListMode.plain,
  );
  return controller;
}
