import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class PostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool canEdit;
  final Post post;

  PostAppBar({@required this.post, this.canEdit = true});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Future<void> download() async {
      String message;
      if (await post.download()) {
        message = 'Saved image #${post.id} to gallery';
      } else {
        message = 'Failed to download post ${post.id}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text(message),
      ));
    }

    return Hero(
      tag: 'appbar',
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: ShadowIcon(
            post.isEditing.value && this.canEdit
                ? Icons.clear
                : Icons.arrow_back,
          ),
          onPressed: Navigator.of(context).maybePop,
        ),
        actions: post.isEditing.value
            ? null
            : [
                PopupMenuButton(
                  icon: ShadowIcon(
                    Icons.more_vert,
                  ),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    PopupMenuTile(
                      value: () async =>
                          Share.share(post.url(await db.host.value).toString()),
                      title: 'Share',
                      icon: Icons.share,
                    ),
                    post.file.value.url != null
                        ? PopupMenuTile(
                            value: download,
                            title: 'Download',
                            icon: Icons.file_download,
                          )
                        : null,
                    PopupMenuTile(
                      value: () async =>
                          launch(post.url(await db.host.value).toString()),
                      title: 'Browse',
                      icon: Icons.open_in_browser,
                    ),
                    post.isLoggedIn && canEdit
                        ? PopupMenuTile(
                            value: () => post.isEditing.value = true,
                            title: 'Edit',
                            icon: Icons.edit,
                          )
                        : null,
                    post.isLoggedIn
                        ? PopupMenuTile(
                            value: () async {
                              if (await writeComment(context, post)) {
                                post.comments.value++;
                              }
                            },
                            title: 'Comment',
                            icon: Icons.comment,
                          )
                        : null,
                  ],
                ),
              ],
      ),
    );
  }
}
