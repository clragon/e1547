import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostsRouteConnector extends StatefulWidget {
  const PostsRouteConnector({
    super.key,
    required this.controller,
    required this.child,
  });

  final PostsController controller;
  final Widget child;

  @override
  State<PostsRouteConnector> createState() => _PostsRouteConnectorState();
}

class _PostsRouteConnectorState extends State<PostsRouteConnector> {
  List<Post>? pageItems;

  @override
  void initState() {
    super.initState();
    pageItems = widget.controller.items;
  }

  void popOrRemove() {
    if (ModalRoute.of(context)!.isCurrent) {
      Navigator.of(context).pop();
    } else if (ModalRoute.of(context)!.isActive) {
      Navigator.of(context).removeRoute(ModalRoute.of(context)!);
    }
  }

  void updatePages() {
    List<Post>? previous = pageItems;
    List<Post>? current = widget.controller.items;
    if (previous == null || current == null) {
      return popOrRemove();
    }
    if (previous.length > current.length) {
      return popOrRemove();
    }
    for (int i = 0; i < previous.length; i++) {
      if (previous[i].id != current[i].id) {
        return popOrRemove();
      }
    }
    pageItems = widget.controller.items;
  }

  @override
  Widget build(BuildContext context) => SubListener(
        listener: updatePages,
        listenable: widget.controller,
        builder: (context) => ChangeNotifierProvider.value(
          value: widget.controller,
          child: widget.child,
        ),
      );
}

class PostsIdConnector extends StatelessWidget {
  const PostsIdConnector({super.key, required this.id, required this.builder});

  final int id;
  final Widget Function(BuildContext context, Post? value) builder;

  @override
  Widget build(BuildContext context) {
    PostsController? controller = context.watch<PostsController>();
    return builder(
      context,
      controller.items?.firstWhereOrNull((e) => e.id == id),
    );
  }
}

class PostsControllerConnector extends StatelessWidget {
  const PostsControllerConnector({
    super.key,
    required this.id,
    required this.controller,
    required this.builder,
  });

  final int id;
  final PostsController controller;
  final Widget Function(BuildContext context, Post? value) builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostsController>.value(
      value: controller,
      child: PostsIdConnector(
        id: id,
        builder: builder,
      ),
    );
  }
}

class PostsConnector extends StatelessWidget {
  const PostsConnector({
    super.key,
    required this.post,
    required this.builder,
  });

  final Post post;
  final Widget Function(BuildContext context, Post value) builder;

  @override
  Widget build(BuildContext context) {
    return PostsIdConnector(
      id: post.id,
      builder: (context, post) => builder(
        context,
        post ?? this.post,
      ),
    );
  }
}

class PostHistoryConnector extends StatelessWidget {
  const PostHistoryConnector({
    super.key,
    required this.post,
    required this.child,
  });

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) => ItemHistoryConnector<Post>(
        item: post,
        addToHistory: (context, service, item) => service.addPost(
          post,
          denylist: context.read<Client>().traits.value.denylist,
        ),
        child: child,
      );
}

class PostsControllerHistoryConnector extends StatelessWidget {
  const PostsControllerHistoryConnector({
    super.key,
    required this.child,
    required this.controller,
  });

  final PostsController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ControllerHistoryConnector<PostsController>(
        controller: controller,
        addToHistory: (context, service, data) => service.addPostSearch(
          data.query,
          posts: data.items,
        ),
        child: child,
      );
}
