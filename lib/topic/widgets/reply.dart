import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';
import 'package:username_generator/username_generator.dart';

class ReplyTile extends StatelessWidget {
  final Topic topic;
  final Reply reply;

  final UsernameGenerator generator = UsernameGenerator();

  ReplyTile({required this.reply, required this.topic});

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
                generator.generate(reply.creatorId),
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
              ' • ${format(reply.createdAt)}'
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
                        child: UsernameGeneratorData(
                          generator: generator,
                          child: DText(reply.body),
                        ),
                      ),
                    ),
                  ],
                )
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
