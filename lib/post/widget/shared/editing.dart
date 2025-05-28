import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostEditor extends StatelessWidget {
  const PostEditor({super.key, required this.child, required this.post});

  final Widget child;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return SubChangeNotifierProvider0<PostEditingController>(
      create: (context) => PostEditingController(post: post),
      update: (context, value) => value..post = post,
      builder: (context, child) {
        PostEditingController controller = context
            .watch<PostEditingController>();
        return PopScope(
          canPop: controller.isShown || !controller.editing,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) controller.stopEditing();
          },
          child: PromptActions(controller: controller, child: child!),
        );
      },
      child: child,
    );
  }
}

class PostEditorChild extends StatelessWidget {
  const PostEditorChild({super.key, required this.child, required this.shown});

  final Widget child;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    return HiddenWidget(
      show:
          shown == (context.watch<PostEditingController?>()?.editing ?? false),
      child: child,
    );
  }
}
