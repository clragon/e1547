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
    return Hero(
      tag: 'appbar',
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: IconShadow(
            icon: Icon(
              post.isEditing.value && this.canEdit
                  ? Icons.clear
                  : Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            shadowColor: Theme.of(context).canvasColor,
          ),
          onPressed: Navigator.of(context).maybePop,
        ),
        actions: post.isEditing.value
            ? null
            : <Widget>[
                Builder(
                  builder: (context) {
                    return PopupMenuButton<String>(
                      icon: IconShadow(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        shadowColor: Colors.black,
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'share',
                          child: PopTile(title: 'Share', icon: Icons.share),
                        ),
                        post.file.value.url != null
                            ? PopupMenuItem(
                                value: 'download',
                                child: PopTile(
                                    title: 'Download',
                                    icon: Icons.file_download),
                              )
                            : null,
                        PopupMenuItem(
                          value: 'browse',
                          child: PopTile(
                              title: 'Browse', icon: Icons.open_in_browser),
                        ),
                        post.isLoggedIn && canEdit
                            ? PopupMenuItem(
                                value: 'edit',
                                child: PopTile(title: 'Edit', icon: Icons.edit),
                              )
                            : null,
                        post.isLoggedIn
                            ? PopupMenuItem(
                                value: 'comment',
                                child: PopTile(
                                    title: 'Comment', icon: Icons.comment),
                              )
                            : null,
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'share':
                            Share.share(
                                post.url(await db.host.value).toString());
                            break;
                          case 'download':
                            String message;
                            if (await post.downloadDialog(context)) {
                              message = 'Saved image #${post.id} to gallery';
                            } else {
                              message = 'Failed to download post ${post.id}';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 1),
                              content: Text(message),
                            ));
                            break;
                          case 'browse':
                            launch(post.url(await db.host.value).toString());
                            break;
                          case 'edit':
                            post.isEditing.value = true;
                            break;
                          case 'comment':
                            if (await writeComment(context, post)) {
                              post.comments.value++;
                            }
                            break;
                        }
                      },
                    );
                  },
                ),
              ],
      ),
    );
  }
}
