import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

List<PopupMenuItem<VoidCallback>> postMenuActions(
    BuildContext context, Post post) {
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
      value: () async => Share.share(post.url(settings.host.value).toString()),
      title: 'Share',
      icon: Icons.share,
    ),
    if (post.file.url != null)
      PopupMenuTile(
        value: download,
        title: 'Download',
        icon: Icons.file_download,
      ),
    PopupMenuTile(
      value: () async => launch(post.url(settings.host.value).toString()),
      title: 'Browse',
      icon: Icons.open_in_browser,
    )
  ];
}

List<PopupMenuItem<VoidCallback>> postMenuUserActions(
    BuildContext context, Post post) {
  return [
    if (post.isLoggedIn)
      PopupMenuTile(
        value: () {
          post.isEditing = true;
          post.notifyListeners();
        },
        title: 'Edit',
        icon: Icons.edit,
      ),
    if (post.isLoggedIn)
      PopupMenuTile(
        value: () async {
          if (await writeComment(context: context, post: post)) {
            post.commentCount++;
            post.notifyListeners();
          }
        },
        title: 'Comment',
        icon: Icons.comment,
      ),
  ];
}
