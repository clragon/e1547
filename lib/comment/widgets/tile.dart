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
    Widget picture() {
      return Padding(
        padding: EdgeInsets.only(right: 8, top: 4),
        child: Icon(Icons.person),
      );
    }

    Widget title() {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: InkWell(
              child: Text(
                comment.creatorName,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.35),
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SearchPage(tags: 'user:${comment.creatorName}');
                }));
              },
            ),
          ),
          Text(
            () {
              String time = ' • ${format(comment.createdAt)}';
              if (comment.createdAt != comment.updatedAt) {
                time += ' (edited)';
              }
              return time;
            }(),
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .color!
                  .withOpacity(0.35),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    Widget body() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: DTextField(source: comment.body),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
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
                if (settings.credentials.value!.username == comment.creatorName)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      onPressed: () => editComment(
                          context: context, post: post, comment: comment),
                    ),
                  ),
              ],
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
