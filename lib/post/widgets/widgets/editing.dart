import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostEditorData extends InheritedNotifier<PostEditingController> {
  const PostEditorData(
      {required Widget child, required PostEditingController controller})
      : super(child: child, notifier: controller);
}

class PostEditor extends StatelessWidget {
  final Widget child;
  final PostEditingController? editingController;

  const PostEditor({
    required this.child,
    this.editingController,
  });

  static PostEditingController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PostEditorData>()
        ?.notifier;
  }

  @override
  Widget build(BuildContext context) {
    if (editingController == null) return child;

    return WillPopScope(
      child: PostEditorData(
        controller: editingController!,
        child: SheetActions(controller: editingController!, child: child),
      ),
      onWillPop: () async {
        if (editingController?.isShown ?? false) {
          return true;
        }
        if (editingController?.editing ?? false) {
          editingController!.stopEditing();
          return false;
        }
        return true;
      },
    );
  }
}

class PostEditorChild extends StatelessWidget {
  final Widget child;
  final bool shown;

  const PostEditorChild({
    required this.child,
    required this.shown,
  });

  @override
  Widget build(BuildContext context) {
    PostEditingController? controller = PostEditor.of(context);
    return CrossFade(
      showChild: shown == (controller?.editing ?? false),
      child: child,
    );
  }
}
