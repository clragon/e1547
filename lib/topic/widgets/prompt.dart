import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

Future<void> showTopicPrompt({
  required BuildContext context,
  required Topic topic,
}) async {
  if (Theme.of(context).isDesktop) {
    showTopicDialog(context: context, topic: topic);
  } else {
    showTopicSheet(context: context, topic: topic);
  }
}

void showTopicSheet({
  required BuildContext context,
  required Topic topic,
}) {
  showSlidingBottomSheet(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      (context, sheetState) => TopicSheet(topic: topic),
    ),
  );
}

class TopicSheet extends StatelessWidget {
  const TopicSheet({super.key, required this.topic});

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
                      style: Theme.of(context).textTheme.titleLarge,
                      softWrap: true,
                    ),
                  ),
                ),
                ActionButton(
                  icon: const Icon(Icons.share),
                  onTap: () async => Share.share(
                    context,
                    context.read<Client>().withHost(topic.link),
                  ),
                  label: const Text('Share'),
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
  const TopicInfo({super.key, required this.topic});

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
                  ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  Clipboard.setData(ClipboardData(
                    text: topic.id.toString(),
                  ));
                  await Navigator.of(context).maybePop();
                  messenger.showSnackBar(SnackBar(
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

Future<void> showTopicDialog({
  required BuildContext context,
  required Topic topic,
}) async {
  await showDialog(
    context: context,
    builder: (context) => TopicDialog(topic: topic),
  );
}

class TopicDialog extends StatelessWidget {
  const TopicDialog({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      style: Theme.of(context).textTheme.titleLarge,
                      softWrap: true,
                    ),
                  ),
                ),
                ActionButton(
                  icon: const Icon(Icons.share),
                  onTap: () async => Share.share(
                    context,
                    context.read<Client>().withHost(topic.link),
                  ),
                  label: const Text('Share'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            TopicInfo(topic: topic),
          ],
        ),
      ),
    );
  }
}
