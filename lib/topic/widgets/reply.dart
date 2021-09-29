import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:username_generator/username_generator.dart';

class ReplyTile extends StatelessWidget {
  final Topic topic;
  final Reply reply;

  final UsernameGenerator generator = UsernameGenerator();

  ReplyTile({required this.reply, required this.topic});

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
                generator.generate(reply.creatorId),
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.35),
                ),
              ),
              onTap: () async => launch(
                  'https://${settings.host.value}/users/${reply.creatorId}'),
            ),
          ),
          Text(
            () {
              String time = ' • ${format(reply.createdAt)}';
              if (reply.createdAt != reply.updatedAt) {
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
              child: DTextField(
                source: reply.body,
                usernameGenerator: generator,
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
          Row(
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
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
