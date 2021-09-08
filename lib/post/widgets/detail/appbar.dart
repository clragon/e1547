import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailAppBar extends StatelessWidget with AppBarSize {
  final Post post;

  PostDetailAppBar({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: post,
      builder: (context, child) => TransparentAppBar(
        leading: IconButton(
          icon: ShadowIcon(post.isEditing ? Icons.clear : Icons.arrow_back),
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
                  itemBuilder: ((context) => [
                        ...postMenuActions(context, post),
                        ...postMenuUserActions(context, post),
                      ]),
                ),
              ],
      ),
    );
  }
}
