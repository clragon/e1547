import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailAppBar extends StatelessWidget with PreferredSizeWidget {
  final PostController post;

  @override
  Size get preferredSize => const Size.fromHeight(defaultAppBarHeight);

  PostDetailAppBar({required this.post});

  @override
  Widget build(BuildContext context) {
    bool isEditing = PostEditor.maybeOf(context)?.editing ?? false;
    return TransparentAppBar(
      child: DefaultAppBar(
        leading: isEditing
            ? IconButton(
                onPressed: Navigator.of(context).maybePop,
                tooltip: 'Stop editing',
                icon: const ShadowIcon(
                  Icons.clear,
                  color: Colors.white,
                ),
              )
            : ShadowBackButton(),
        actions: isEditing
            ? null
            : [
                PopupMenuButton<VoidCallback>(
                  icon: const ShadowIcon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    ...postMenuPostActions(context, post.value),
                    ...postMenuUserActions(
                      context,
                      post,
                    ),
                  ],
                ),
              ],
      ),
    );
  }
}
