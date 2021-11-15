import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailAppBar extends StatelessWidget with AppBarSize {
  final Post post;

  PostDetailAppBar({required this.post});

  @override
  Size get preferredSize => Size.fromHeight(defaultAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.isEditing],
      builder: (context, child) => TransparentAppBar(
        leading: IconButton(
          icon: ShadowIcon(
            post.isEditing ? Icons.clear : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: Navigator.of(context).maybePop,
        ),
        actions: post.isEditing
            ? null
            : [
                PopupMenuButton<VoidCallback>(
                  icon: ShadowIcon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) => value(),
                  itemBuilder: ((context) => [
                        ...postMenuPostActions(context, post),
                        ...postMenuUserActions(context, post),
                      ]),
                ),
              ],
      ),
    );
  }
}
