import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:username_generator/username_generator.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Hero(
            tag: comment.hero,
            child: Row(
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
                      CommentHeader(comment: comment),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Expanded(child: DText(comment.body))],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                child: switch (flightDirection) {
                  HeroFlightDirection.push => fromHeroContext.widget,
                  HeroFlightDirection.pop => toHeroContext.widget,
                },
              ),
            ),
          ),
          if (hasActions)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommentVotes(comment: comment),
                  const Spacer(),
                  CommentMenu(comment: comment),
                ],
              ),
            ),
          CommentWarnings(comment: comment),
          const Divider(),
        ],
      ),
    );
  }
}

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return TimedText(
      created: comment.createdAt,
      updated: comment.updatedAt,
      child: Dimmed(
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: context.watch<Client>().hasFeature(ClientFeature.users)
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserLoadingPage(
                        comment.creatorId.toString(),
                      ),
                    ),
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    comment.creatorName ??
                        context
                            .watch<UsernameGenerator>()
                            .generate(comment.creatorId),
                  ),
                ),
                if (comment.creatorName == null)
                  const Tooltip(
                    message: 'Generated username',
                    child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.theater_comedy),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommentVotes extends StatelessWidget {
  const CommentVotes({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    VoteInfo? vote = comment.vote;
    if (!client.hasFeature(CommentFeature.vote)) return const SizedBox();
    if (vote == null) return const SizedBox();

    final controller = context.read<CommentController>();
    final messenger = ScaffoldMessenger.of(context);

    return Dimmed(
      child: VoteDisplay(
        padding: EdgeInsets.zero,
        score: vote.score,
        status: vote.status,
        onUpvote: client.hasLogin
            ? (isLiked) async {
                controller
                    .vote(comment: comment, upvote: true, replace: !isLiked)
                    .then((value) {
                  if (!value) {
                    messenger.showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('Failed to upvote comment #${comment.id}'),
                    ));
                  }
                });
                return !isLiked;
              }
            : null,
        onDownvote: client.hasLogin
            ? (isLiked) async {
                controller
                    .vote(comment: comment, upvote: false, replace: !isLiked)
                    .then((value) {
                  if (!value) {
                    messenger.showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content:
                          Text('Failed to downvote comment #${comment.id}'),
                    ));
                  }
                });
                return !isLiked;
              }
            : null,
      ),
    );
  }
}

class CommentMenu extends StatelessWidget {
  const CommentMenu({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    return PopupMenuButton<VoidCallback>(
      icon: const Dimmed(child: Icon(Icons.more_vert)),
      onSelected: (value) => value(),
      itemBuilder: (context) => [
        if (client.hasFeature(CommentFeature.update) &&
            client.identity.username == comment.creatorName)
          PopupMenuTile(
            title: 'Edit',
            icon: Icons.edit,
            value: () => guardWithLogin(
              context: context,
              callback: () {
                CommentController controller =
                    context.read<CommentController>();
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
        if (client.hasFeature(CommentFeature.post))
          PopupMenuTile(
            title: 'Reply',
            icon: Icons.reply,
            value: () => guardWithLogin(
              context: context,
              callback: () {
                CommentController controller =
                    context.read<CommentController>();
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
        if (client.hasFeature(CommentFeature.report))
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
    );
  }
}

class CommentWarnings extends StatelessWidget {
  const CommentWarnings({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    WarningType? warning = comment.warning;
    if (warning == null) return const SizedBox();
    return Padding(
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
            warning.message,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ),
    );
  }
}
