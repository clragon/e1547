import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostFullscreenAppBar extends StatelessWidget with AppBarSize {
  final Post post;

  PostFullscreenAppBar({required this.post});

  @override
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      leading: ShadowBackButton(),
      actions: post.isEditing
          ? null
          : [
              PopupMenuButton<VoidCallback>(
                icon: ShadowIcon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onSelected: (value) => value(),
                itemBuilder: (context) => postMenuPostActions(context, post),
              ),
            ],
    );
  }
}
