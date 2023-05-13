import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostDetailAppBar({required this.post});

  final Post post;

  @override
  Size get preferredSize => const Size.fromHeight(defaultAppBarHeight);

  @override
  Widget build(BuildContext context) {
    bool isEditing = context.watch<PostEditingController?>()?.editing ?? false;
    return TransparentAppBar(
      child: DefaultAppBar(
        leading: isEditing ? const CloseButton() : null,
        actions: isEditing
            ? null
            : [
                PopupMenuButton<VoidCallback>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    ...postMenuPostActions(context, post),
                    ...postMenuUserActions(context, post),
                  ],
                ),
              ],
      ),
    );
  }
}
