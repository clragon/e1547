import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostLoadingPage extends StatelessWidget {
  const PostLoadingPage(this.id, {super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return SingleFuturePostsProvider(
      id: id,
      child: Consumer<Future<PostController>>(
        builder: (context, controller, child) =>
            FutureLoadingPage<PostController>(
          future: controller,
          builder: (context, value) => PostsRouteConnector(
            controller: value,
            child: PostDetailGallery(controller: value),
          ),
          title: Text('Post #$id'),
          onError: const Text('Failed to load post'),
          onEmpty: const Text('Post not found'),
        ),
      ),
    );
  }
}

class SingleFuturePostsProvider
    extends SubProvider<Client, Future<PostController>> {
  SingleFuturePostsProvider({required int id, super.child, super.builder})
      : super(
          create: (context, client) => Future<PostController>(() async {
            PostController controller = SinglePostController(
              id: id,
              client: client,
            );
            await controller.getNextPage();
            return controller;
          }),
          keys: (context) => [id],
          dispose: (context, value) async => (await value).dispose(),
        );
}
