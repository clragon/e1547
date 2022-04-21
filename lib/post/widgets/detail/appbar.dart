import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailAppBar extends StatelessWidget with PreferredSizeWidget {
  final Post post;
  final PostController? controller;

  @override
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);

  PostDetailAppBar({
    required this.post,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool isEditing = PostEditor.of(context)?.editing ?? false;
    return TransparentAppBar(
      child: DefaultAppBar(
        leading: isEditing
            ? IconButton(
                onPressed: Navigator.of(context).maybePop,
                tooltip: 'Stop editing',
                icon: ShadowIcon(
                  Icons.clear,
                  color: Colors.white,
                ),
              )
            : ShadowBackButton(),
        actions: isEditing
            ? null
            : [
                PopupMenuButton<VoidCallback>(
                  icon: ShadowIcon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    ...postMenuPostActions(context, post),
                    ...postMenuUserActions(
                      context,
                      post,
                      controller: controller,
                    ),
                  ],
                ),
              ],
      ),
    );
  }
}
