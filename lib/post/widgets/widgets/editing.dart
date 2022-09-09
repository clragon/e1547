import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostEditor extends StatelessWidget {
  const PostEditor({
    required this.child,
    required this.post,
  });

  final Widget child;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return SubChangeNotifierProvider0<PostEditingController>(
      create: (context) => PostEditingController(post: post),
      update: (context, value) => value..post = post,
      builder: (context, child) => WillPopScope(
        child: SheetActions(
          controller: context.watch<PostEditingController>(),
          child: child!,
        ),
        onWillPop: () async {
          PostEditingController controller =
              context.read<PostEditingController>();
          if (controller.isShown) {
            return true;
          }
          if (controller.editing) {
            controller.stopEditing();
            return false;
          }
          return true;
        },
      ),
      child: child,
    );
  }
}

class PostEditorChild extends StatelessWidget {
  const PostEditorChild({
    required this.child,
    required this.shown,
  });

  final Widget child;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild:
          shown == (context.watch<PostEditingController?>()?.editing ?? false),
      child: child,
    );
  }
}
