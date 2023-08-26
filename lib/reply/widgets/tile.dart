import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';
import 'package:username_generator/username_generator.dart';

class ReplyTile extends StatelessWidget {
  const ReplyTile({required this.reply, required this.topic});

  final Topic topic;
  final Reply reply;

  @override
  Widget build(BuildContext context) {
    Widget picture() {
      return const Padding(
        padding: EdgeInsets.only(right: 8, top: 4),
        child: Icon(Icons.person),
      );
    }

    Widget title() {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: InkWell(
              child: Text(
                context.watch<UsernameGenerator>().generate(reply.creatorId),
                style: TextStyle(
                  color: dimTextColor(context),
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
          ),
          Flexible(
            child: Text(
              ' • ${reply.createdAt.relativeTime(context)}'
              '${reply.createdAt != reply.updatedAt ? ' (edited)' : ''}',
              style: TextStyle(
                color: dimTextColor(context),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget body() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          picture(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DText(reply.body),
                      ),
                    ),
                  ],
                ),
                if (reply.warningType != null)
                  Row(
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
                        reply.warningType!.message,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  ),
              ],
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
            tag: reply.hero,
            child: Material(
              type: MaterialType.transparency,
              child: body(),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
