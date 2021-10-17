import 'package:e1547/comment/comment.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class CommentTile extends StatelessWidget {
  final Post post;
  final Comment comment;

  const CommentTile({required this.comment, required this.post});

  @override
  Widget build(BuildContext context) {
    final Color dark =
        Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.35);

    Widget picture() {
      return Padding(
        padding: EdgeInsets.only(right: 8, top: 4),
        child: Icon(Icons.person),
      );
    }

    Widget title() {
      return DefaultTextStyle(
        style: TextStyle(color: dark),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                child: Text(comment.creatorName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchPage(tags: 'user:${comment.creatorName}'),
                  ),
                ),
              ),
            ),
            Text(
              ' • ${format(comment.createdAt)}${comment.createdAt != comment.updatedAt ? ' (edited)' : ''}',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    Widget body() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DTextField(source: comment.body),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  picture(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title(),
                        body(),
                      ],
                    ),
                  ),
                  if (settings.credentials.value!.username ==
                      comment.creatorName)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editComment(
                            context: context, post: post, comment: comment),
                      ),
                    ),
                ],
              ),
            ),
            onTap: post.isLoggedIn
                ? () =>
                    replyComment(context: context, post: post, comment: comment)
                : null,
          ),
          Divider(),
        ],
      ),
    );
  }
}
