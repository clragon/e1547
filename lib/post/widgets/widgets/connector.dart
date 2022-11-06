import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

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
  late List<Post>? pageItems = widget.controller.itemList;

  void popOrRemove() {
    if (ModalRoute.of(context)!.isCurrent) {
      Navigator.of(context).pop();
    } else if (ModalRoute.of(context)!.isActive) {
      Navigator.of(context).removeRoute(ModalRoute.of(context)!);
    }
  }

  void updatePages() {
    if (pageItems == null || widget.controller.itemList == null) {
      return popOrRemove();
    }
    for (int i = 0; i < pageItems!.length; i++) {
      if (pageItems![i].id != widget.controller.itemList![i].id) {
        return popOrRemove();
      }
    }
    pageItems = widget.controller.itemList;
  }

  @override
  Widget build(BuildContext context) => ListenableListener(
        listener: updatePages,
        listenable: widget.controller,
        child: widget.child,
      );
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
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => builder(
          context,
          controller.itemList?.firstWhereOrNull((e) => e.id == id),
        ),
      ),
    );
  }
}

class PostHistoryConnector extends StatefulWidget {
  const PostHistoryConnector({
    super.key,
    required this.post,
    required this.child,
  });

  final Post post;
  final Widget child;

  @override
  State<PostHistoryConnector> createState() => _PostHistoryConnectorState();
}

class _PostHistoryConnectorState extends State<PostHistoryConnector> {
  void addToHistory(Post post) {
    context.read<HistoriesService>().addPost(
          context.read<Client>().host,
          widget.post,
        );
  }

  @override
  void initState() {
    super.initState();
    addToHistory(widget.post);
  }

  @override
  void didUpdateWidget(covariant PostHistoryConnector oldWidget) {
    if (oldWidget.post != widget.post) {
      addToHistory(widget.post);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
