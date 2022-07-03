import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

List<PopupMenuItem<VoidCallback>> postMenuPostActions(
    BuildContext context, Post post) {
  return [
    PopupMenuTile(
      value: () async => Share.share(post.url(client.host).toString()),
      title: 'Share',
      icon: Icons.share,
    ),
    if (post.file.url != null)
      PopupMenuTile(
        value: () => postDownloadingNotification(context, {post}),
        title: 'Download',
        icon: Icons.file_download,
      ),
    PopupMenuTile(
      value: () async => launch(post.url(client.host).toString()),
      title: 'Browse',
      icon: Icons.open_in_browser,
    ),
  ];
}

List<PopupMenuItem<VoidCallback>> postMenuUserActions(
  BuildContext context,
  PostController post,
) {
  return [
    if (PostEditor.maybeOf(context) != null)
      PopupMenuTile(
        title: 'Edit',
        icon: Icons.edit,
        value: () => guardWithLogin(
          context: context,
          callback: PostEditor.of(context).startEditing,
          error: 'You must be logged in to edit posts!',
        ),
      ),
    PopupMenuTile(
      title: 'Comment',
      icon: Icons.comment,
      value: () => guardWithLogin(
        context: context,
        callback: () async {
          if (await writeComment(context: context, postId: post.value.id)) {
            post.value =
                post.value.copyWith(commentCount: post.value.commentCount + 1);
          }
        },
        error: 'You must be logged in to comment!',
      ),
    ),
    PopupMenuTile(
      title: 'Report',
      icon: Icons.report,
      value: () => guardWithLogin(
        context: context,
        callback: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostReportScreen(post: post),
          ),
        ),
        error: 'You must be logged in to report posts!',
      ),
    ),
    PopupMenuTile(
      title: 'Flag',
      icon: Icons.flag,
      value: () => guardWithLogin(
        context: context,
        callback: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostFlagScreen(post: post),
          ),
        ),
        error: 'You must be logged in to flag posts!',
      ),
    ),
  ];
}
