import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostLoadingPage extends StatefulWidget {
  final int id;

  const PostLoadingPage(this.id);

  @override
  State<PostLoadingPage> createState() => _PostLoadingPageState();
}

class _PostLoadingPageState extends State<PostLoadingPage> {
  late PostsController controller = PostsController.single(widget.id);
  late Future<PostsController> firstPage =
      controller.loadFirstPage().then((_) => controller);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<PostsController>(
      future: firstPage,
      builder: (context, value) => PostDetailGallery(controller: value),
      title: Text('Post #${widget.id}'),
      onError: const Text('Failed to load post'),
      onEmpty: const Text('Post not found'),
    );
  }
}
