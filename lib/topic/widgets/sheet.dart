import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

void topicSheet(BuildContext context, Topic topic) {
  showSlidingBottomSheet(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      (context, sheetState) => TopicSheet(topic: topic),
    ),
  );
}

class TopicSheet extends StatelessWidget {
  const TopicSheet({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tagToRaw(topic.title),
                      style: Theme.of(context).textTheme.headline6,
                      softWrap: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async => Share.share(
                    context,
                    context.read<Client>().withHost(topic.link),
                  ),
                  tooltip: 'Share',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TopicInfo(topic: topic),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicInfo extends StatelessWidget {
  const TopicInfo({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    Widget textInfoRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      );
    }

    return DefaultTextStyle(
      style: TextStyle(
        color: dimTextColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow('replies', topic.responseCount.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('id'),
              InkWell(
                child: Text(
                  '#${topic.id}',
                ),
                onLongPress: () async {
                  Clipboard.setData(ClipboardData(
                    text: topic.id.toString(),
                  ));
                  await Navigator.of(context).maybePop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text('Copied topic id #${topic.id}'),
                  ));
                },
              ),
            ],
          ),
          textInfoRow(
            'locked',
            topic.isLocked ? 'yes' : 'no',
          ),
          textInfoRow(
            'sticky',
            topic.isSticky ? 'yes' : 'no',
          ),
          textInfoRow(
            'created',
            formatDateTime(topic.createdAt.toLocal()),
          ),
          textInfoRow(
            'updated',
            formatDateTime(
              topic.updatedAt.toLocal(),
            ),
          ),
        ],
      ),
    );
  }
}
