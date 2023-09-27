import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.hasActions = true,
  });

  final Comment comment;
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return TimedText(
        created: comment.createdAt,
        updated: comment.updatedAt,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: dimTextColor(context),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              child: Text(comment.creatorName),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserLoadingPage(
                    comment.creatorId.toString(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget body() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, top: 4),
            child: Icon(Icons.person),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: DText(comment.body))],
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget actions() {
      return Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DimSubtree(
              child: VoteDisplay(
                padding: EdgeInsets.zero,
                score: comment.score,
                status: comment.voteStatus,
                onUpvote: context.read<Client>().hasLogin
                    ? (isLiked) async {
                        CommentsController controller =
                            context.read<CommentsController>();
                        ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        controller
                            .vote(
                                comment: comment,
                                upvote: true,
                                replace: !isLiked)
                            .then((value) {
                          if (!value) {
                            messenger.showSnackBar(SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                  'Failed to upvote comment #${comment.id}'),
                            ));
                          }
                        });
                        return !isLiked;
                      }
                    : null,
                onDownvote: context.read<Client>().hasLogin
                    ? (isLiked) async {
                        CommentsController controller =
                            context.read<CommentsController>();
                        ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        controller
                            .vote(
                                comment: comment,
                                upvote: false,
                                replace: !isLiked)
                            .then((value) {
                          if (!value) {
                            messenger.showSnackBar(SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                  'Failed to downvote comment #${comment.id}'),
                            ));
                          }
                        });
                        return !isLiked;
                      }
                    : null,
              ),
            ),
            const Spacer(),
            PopupMenuButton<VoidCallback>(
              icon: const DimSubtree(child: Icon(Icons.more_vert)),
              onSelected: (value) => value(),
              itemBuilder: (context) => [
                if (context.read<Client>().identity.username ==
                    comment.creatorName)
                  PopupMenuTile(
                    title: 'Edit',
                    icon: Icons.edit,
                    value: () => guardWithLogin(
                      context: context,
                      callback: () {
                        CommentsController controller =
                            context.read<CommentsController>();
                        editComment(
                          context: context,
                          comment: comment,
                        ).then((value) {
                          if (value) {
                            controller.refresh(force: true);
                          }
                        });
                      },
                      error: 'You must be logged in to edit comments!',
                    ),
                  ),
                PopupMenuTile(
                  title: 'Reply',
                  icon: Icons.reply,
                  value: () => guardWithLogin(
                    context: context,
                    callback: () {
                      CommentsController controller =
                          context.read<CommentsController>();
                      replyComment(
                        context: context,
                        comment: comment,
                      ).then((value) {
                        if (value) {
                          controller.refresh(force: true);
                        }
                      });
                    },
                    error: 'You must be logged in to reply to comments!',
                  ),
                ),
                PopupMenuTile(
                  title: 'Copy ID',
                  icon: Icons.tag,
                  value: () async {
                    Clipboard.setData(
                      ClipboardData(text: comment.id.toString()),
                    );
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
            ),
          ],
        ),
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
          if (hasActions) actions(),
          if (comment.warningType != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.warning_amber,
                      size: smallIconSize(context),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  Text(
                    comment.warningType!.message,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.error,
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
