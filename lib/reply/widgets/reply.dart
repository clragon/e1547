import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:username_generator/username_generator.dart';

class ReplyTile extends StatelessWidget {
  const ReplyTile({
    super.key,
    required this.reply,
  });

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Hero(
            tag: reply.hero,
            child: Material(
              type: MaterialType.transparency,
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
                        ReplyHeader(reply: reply),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Expanded(child: DText(reply.body))],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ReplyWarning(reply: reply),
          const Divider(),
        ],
      ),
    );
  }
}

class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
    super.key,
    required this.reply,
  });

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    return Dimmed(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: TimedText(
          created: reply.createdAt,
          updated: reply.updatedAt,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    context
                        .watch<UsernameGenerator>()
                        .generate(reply.creatorId),
                    style: TextStyle(
                      color: dimTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Tooltip(
                  message: 'Generated username',
                  child: Icon(Icons.theater_comedy),
                ),
              ],
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserLoadingPage(
              reply.creatorId.toString(),
            ),
          ),
        ),
      ),
    );
  }
}

class ReplyWarning extends StatelessWidget {
  const ReplyWarning({
    super.key,
    required this.reply,
  });

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    WarningType? warning = reply.warning;
    if (warning == null) return const SizedBox();
    return Row(
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
    );
  }
}
