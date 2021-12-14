import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback? onPressed;
  final VoidCallback? onCountPressed;

  const TopicTile({
    required this.topic,
    this.onPressed,
    this.onCountPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                tagToName(topic.title),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
          InkWell(
            onTap: onCountPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          ),
        ],
      );
    }

    return Card(
      child: InkWell(
        onTap: onPressed,
        onLongPress: () => topicSheet(context, topic),
        child: title(),
      ),
    );
  }
}
