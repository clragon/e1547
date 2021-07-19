import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailAppBar extends StatelessWidget with AppBarSizeMixin {
  final Post post;

  PostDetailAppBar({@required this.post});

  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      leading: IconButton(
        icon: ShadowIcon(post.isEditing.value ? Icons.clear : Icons.arrow_back),
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
                  ...postMenuActions(context, post),
                  ...postMenuUserActions(context, post),
                ],
              ),
            ],
    );
  }
}

class PostPhotoAppBar extends StatelessWidget with AppBarSizeMixin {
  final Post post;

  PostPhotoAppBar({@required this.post});

  @override
  Widget build(BuildContext context) {
    return TransparentAppBar(
      leading: IconButton(
        icon: ShadowIcon(Icons.arrow_back),
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
                itemBuilder: (context) => postMenuActions(context, post),
              ),
            ],
    );
  }
}

List<PopupMenuItem> postMenuActions(BuildContext context, Post post) {
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

  return [
    PopupMenuTile(
      value: () async => Share.share(post.url(await db.host.value).toString()),
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
      value: () async => launch(post.url(await db.host.value).toString()),
      title: 'Browse',
      icon: Icons.open_in_browser,
    )
  ];
}

List<PopupMenuItem> postMenuUserActions(BuildContext context, Post post) {
  return [
    post.isLoggedIn
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
  ];
}
