import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback? onPressed;

  TopicTile({
    required this.topic,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tagToName(topic.title),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                topic.responseCount.toString(),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: this.onPressed,
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
