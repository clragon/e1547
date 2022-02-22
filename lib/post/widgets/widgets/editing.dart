import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/data/editing.dart';
import 'package:flutter/material.dart';

class PostEditingScope extends StatelessWidget {
  final Widget child;
  final PostEditingController? editingController;
  final SheetActionController? sheetController;

  const PostEditingScope({
    required this.child,
    this.editingController,
    this.sheetController,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (sheetController?.isShown ?? false) {
          return true;
        }
        if (editingController?.editing ?? false) {
          editingController!.stopEditing();
          return false;
        }
        return true;
      },
      child: child,
    );
  }
}

class PostEditingDependant extends StatelessWidget {
  final Widget child;
  final bool shown;
  final PostEditingController? controller;

  const PostEditingDependant({
    required this.child,
    required this.shown,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller]),
      builder: (context, child) => CrossFade(
        showChild: shown == (controller?.editing ?? false),
        child: child!,
      ),
      child: child,
    );
  }
}
