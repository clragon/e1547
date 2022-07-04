import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailConnector extends StatefulWidget {
  final PostsController controller;
  final Widget child;

  const PostDetailConnector({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<PostDetailConnector> createState() => _PostDetailConnectorState();
}

class _PostDetailConnectorState extends State<PostDetailConnector>
    with ListenerCallbackMixin {
  late List<Post>? pageItems = widget.controller.itemList;

  @override
  Map<Listenable, VoidCallback> get listeners => {
        widget.controller: updatePages,
      };

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
  Widget build(BuildContext context) => widget.child;
}
