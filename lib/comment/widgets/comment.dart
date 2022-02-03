import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final bool hasActions;

  const CommentTile({
    required this.comment,
    this.hasActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = 18;

    Widget picture() {
      return Padding(
        padding: EdgeInsets.only(right: 8, top: 4),
        child: Icon(Icons.person),
      );
    }

    Widget title() {
      return DefaultTextStyle(
        style: TextStyle(color: dimTextColor(context)),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                child: Text(comment.creatorName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        UserLoadingPage(comment.creatorId.toString()),
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
          picture(),
          Expanded(
            child: GestureDetector(
              onTap: hasActions && client.hasLogin
                  ? () => replyComment(context: context, comment: comment)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DText(
                          comment.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Hero(
            tag: comment.hero,
            child: body(),
            flightShuttleBuilder: (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) =>
                Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: body(),
              ),
            ),
          ),
          if (hasActions)
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: dimTextColor(context),
                        ),
                    child: IconTheme(
                      data: Theme.of(context).iconTheme.copyWith(
                            color: dimTextColor(context),
                            size: iconSize,
                          ),
                      child: AnimatedSelector(
                        selector: () => [comment.voteStatus],
                        animation: comment,
                        builder: (context, child) => VoteDisplay(
                          padding: EdgeInsets.zero,
                          score: comment.score,
                          status: comment.voteStatus,
                          onUpvote: (isLiked) async {
                            if (client.hasLogin) {
                              comment.tryVote(
                                  context: context,
                                  upvote: true,
                                  replace: !isLiked);
                              return !isLiked;
                            } else {
                              return false;
                            }
                          },
                          onDownvote: (isLiked) async {
                            if (client.hasLogin) {
                              comment.tryVote(
                                  context: context,
                                  upvote: false,
                                  replace: !isLiked);
                              return !isLiked;
                            } else {
                              return false;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  PopupMenuButton<VoidCallback>(
                    icon: Icon(
                      Icons.more_vert,
                      size: iconSize,
                      color: dimTextColor(context),
                    ),
                    onSelected: (value) => value(),
                    itemBuilder: (context) => [
                      if (settings.credentials.value?.username ==
                          comment.creatorName)
                        PopupMenuTile(
                          title: 'Edit',
                          icon: Icons.edit,
                          value: () => editComment(
                            context: context,
                            comment: comment,
                          ),
                        ),
                      PopupMenuTile(
                        title: 'Reply',
                        icon: Icons.reply,
                        value: () => guardWithLogin(
                          context: context,
                          callback: () => replyComment(
                            context: context,
                            comment: comment,
                          ),
                          error: 'You must be logged in to reply to comments!',
                        ),
                      ),
                      PopupMenuTile(
                        title: 'Copy ID',
                        icon: Icons.tag,
                        value: () async {
                          Clipboard.setData(
                              ClipboardData(text: comment.id.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('Copied comment id #${comment.id}'),
                          ));
                        },
                      ),
                      PopupMenuTile(
                        title: 'Report',
                        icon: Icons.report,
                        value: () => guardWithLogin(
                          context: context,
                          callback: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CommentReportScreen(
                                comment: comment,
                              ),
                            ),
                          ),
                          error: 'You must be logged in to report comments!',
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          Divider(),
        ],
      ),
    );
  }
}
