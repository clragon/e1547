import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/comment/data/warning.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relative_time/relative_time.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final CommentController? controller;
  final bool hasActions;

  const CommentTile({
    required this.comment,
    this.controller,
    this.hasActions = true,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 18;

    Widget picture() {
      return const Padding(
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
              padding: const EdgeInsets.symmetric(vertical: 4),
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
              ' • ${comment.createdAt.relativeTime(context: context)}${comment.createdAt != comment.updatedAt ? ' (edited)' : ''}',
              style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                physics: const NeverScrollableScrollPhysics(),
                child: body(),
              ),
            ),
          ),
          if (hasActions)
            Padding(
              padding: const EdgeInsets.only(left: 24),
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
                        animation: Listenable.merge([controller]),
                        selector: () => [comment.voteStatus],
                        builder: (context, child) => VoteDisplay(
                          padding: EdgeInsets.zero,
                          score: comment.score,
                          status: comment.voteStatus,
                          onUpvote: controller != null
                              ? (isLiked) async {
                                  if (client.hasLogin) {
                                    controller!
                                        .vote(
                                      comment: comment,
                                      upvote: true,
                                      replace: !isLiked,
                                    )
                                        .then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(
                                            'Failed to upvote comment #${comment.id}'),
                                      ));
                                    });
                                    return !isLiked;
                                  } else {
                                    return false;
                                  }
                                }
                              : null,
                          onDownvote: controller != null
                              ? (isLiked) async {
                                  if (client.hasLogin) {
                                    controller!
                                        .vote(
                                      comment: comment,
                                      upvote: false,
                                      replace: !isLiked,
                                    )
                                        .then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(
                                            'Failed to downvote comment #${comment.id}'),
                                      ));
                                    });
                                    return !isLiked;
                                  } else {
                                    return false;
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<VoidCallback>(
                    icon: Icon(
                      Icons.more_vert,
                      size: iconSize,
                      color: dimTextColor(context),
                    ),
                    onSelected: (value) => value(),
                    itemBuilder: (context) => [
                      if (client.credentials?.username == comment.creatorName)
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
                            duration: const Duration(seconds: 1),
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
          if (comment.warningType != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.warning_amber,
                      size: iconSize,
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                  Text(
                    MessageWarning.byId(comment.warningType!).message,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Theme.of(context).errorColor,
                        ),
                  ),
                ],
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
