import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostFullscreenAppBar extends StatelessWidget with AppBarSize {
  final Post post;

  PostFullscreenAppBar({required this.post});

  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      leading: IconButton(
        icon: ShadowIcon(Icons.arrow_back),
        onPressed: Navigator.of(context).maybePop,
      ),
      actions: post.isEditing
          ? null
          : [
              PopupMenuButton<VoidCallback>(
                icon: ShadowIcon(
                  Icons.more_vert,
                ),
                onSelected: (value) => value(),
                itemBuilder: ((context) => postMenuActions(context, post)),
              ),
            ],
    );
  }
}
