import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostFullscreenAppBar extends StatelessWidget with PreferredSizeWidget {
  final Post post;
  final bool isEditing;

  PostFullscreenAppBar({required this.post, this.isEditing = false});

  @override
  Size get preferredSize => const Size.fromHeight(defaultAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      child: DefaultAppBar(
        leading: ShadowBackButton(),
        actions: isEditing
            ? null
            : [
                PopupMenuButton<VoidCallback>(
                  icon: const ShadowIcon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => postMenuPostActions(context, post),
                ),
              ],
      ),
    );
  }
}
