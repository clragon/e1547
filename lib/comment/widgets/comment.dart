import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/comment/data/warning.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    this.hasActions = true,
  });

  final CommentController comment;
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return TimedText(
        created: comment.value.createdAt,
        updated: comment.value.updatedAt,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
                color: dimTextColor(context),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              child: Text(comment.value.creatorName),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserLoadingPage(
                    comment.value.creatorId.toString(),
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
                  children: [Expanded(child: DText(comment.value.body))],
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
              child: AnimatedSelector(
                animation: comment,
                selector: () => [comment.value.voteStatus],
                builder: (context, child) => VoteDisplay(
                  padding: EdgeInsets.zero,
                  score: comment.value.score,
                  status: comment.value.voteStatus,
                  onUpvote: context.read<Client>().hasLogin
                      ? (isLiked) async {
                          comment
                              .vote(upvote: true, replace: !isLiked)
                              .then((value) {
                            if (!value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
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
                          comment
                              .vote(upvote: false, replace: !isLiked)
                              .then((value) {
                            if (!value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
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
            ),
            const Spacer(),
            PopupMenuButton<VoidCallback>(
              icon: const DimSubtree(child: Icon(Icons.more_vert)),
              onSelected: (value) => value(),
              itemBuilder: (context) => [
                if (context.read<Client>().credentials?.username ==
                    comment.value.creatorName)
                  PopupMenuTile(
                    title: 'Edit',
                    icon: Icons.edit,
                    value: () => guardWithLogin(
                      context: context,
                      // TODO refresh controller
                      callback: () => editComment(
                        context: context,
                        comment: comment.value,
                      ),
                      error: 'You must be logged in to edit comments!',
                    ),
                  ),
                PopupMenuTile(
                  title: 'Reply',
                  icon: Icons.reply,
                  value: () => guardWithLogin(
                    context: context,
                    // TODO refresh controller
                    callback: () => replyComment(
                      context: context,
                      comment: comment.value,
                    ),
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
            tag: comment.value.hero,
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
          if (comment.value.warningType != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.warning_amber,
                      size: smallIconSize(context),
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                  Text(
                    MessageWarning.byId(comment.value.warningType!).message,
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
