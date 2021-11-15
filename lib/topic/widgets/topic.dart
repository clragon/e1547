import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback? onPressed;

  const TopicTile({
    required this.topic,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tagToName(topic.title),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    topic.responseCount.toString(),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    format(topic.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: onPressed,
        onLongPress: () => topicSheet(context, topic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(),
          ],
        ),
      ),
    );
  }
}
