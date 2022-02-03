import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

void topicSheet(BuildContext context, Topic topic) {
  showSlidingBottomSheet(
    context,
    builder: (BuildContext context) {
      return SlidingSheetDialog(
        duration: Duration(milliseconds: 400),
        isBackdropInteractable: true,
        cornerRadius: 16,
        minHeight: MediaQuery.of(context).size.height * 0.6,
        builder: (context, sheetState) {
          return TopicSheet(
            topic: topic,
          );
        },
        snapSpec: SnapSpec(
          snap: true,
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [
            0.6,
            SnapSpec.expanded,
          ],
        ),
      );
    },
  );
}

class TopicSheet extends StatelessWidget {
  final Topic topic;

  const TopicSheet({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tagToName(topic.title),
                      style: Theme.of(context).textTheme.headline6,
                      softWrap: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async =>
                      Share.share(topic.url(settings.host.value).toString()),
                  tooltip: 'Share',
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TopicInfo(topic: topic),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicInfo extends StatelessWidget {
  final Topic topic;

  const TopicInfo({required this.topic});

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
          color:
              Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow('replies', topic.responseCount.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('id'),
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
                    duration: Duration(seconds: 1),
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
            getCurrentDateTimeFormat().format(topic.createdAt.toLocal()),
          ),
          textInfoRow(
            'updated',
            getCurrentDateTimeFormat().format(
              topic.updatedAt.toLocal(),
            ),
          ),
        ],
      ),
    );
  }
}
