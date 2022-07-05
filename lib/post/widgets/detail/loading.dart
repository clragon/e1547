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
  late Future<PostsController> post =
      PostsController.single(widget.id).loadFirstPage();

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<PostsController>(
      future: post,
      builder: (context, value) => PostDetailConnector(
        controller: value,
        child: PostDetailGallery(controller: value),
      ),
      title: Text('Post #${widget.id}'),
      onError: const Text('Failed to load post'),
      onEmpty: const Text('Post not found'),
    );
  }
}
