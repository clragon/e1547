import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TagCard extends StatelessWidget {
  final String tag;
  final String category;
  final VoidCallback? onRemove;
  final PostProvider? provider;

  TagCard({
    required this.tag,
    required this.category,
    required this.provider,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // card widget tanks performance
    // but we cannot have ripple without material
    return Card(
      child: TagGesture(
        tag: tag,
        provider: provider,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 26,
              decoration: BoxDecoration(
                color: getCategoryColor(category),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4)),
              ),
              child: CrossFade(
                showChild: onRemove != null,
                child: InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.clear, size: 16),
                  ),
                  onTap: onRemove,
                ),
                secondChild: Container(width: 5),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                child: Text(
                  tagToCard(tag),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagCounterCard extends StatelessWidget {
  final String tag;
  final int count;
  final String category;
  final PostProvider provider;

  TagCounterCard({
    required this.tag,
    required this.category,
    required this.provider,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TagGesture(
        wiki: true,
        tag: tag,
        provider: provider,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 26,
              width: 5,
              decoration: BoxDecoration(
                color: getCategoryColor(category),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4)),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, right: 6, left: 6),
                child: Text(
                  tagToCard(tag),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 18,
              color: Theme.of(context).dividerColor,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  count.toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DenyListTagCard extends StatelessWidget {
  final String tag;

  const DenyListTagCard(this.tag);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TagGesture(
        wiki: true,
        tag: tag,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 26,
              width: 5,
              decoration: BoxDecoration(
                color: () {
                  String prefix = tag[0];

                  switch (prefix) {
                    case '-':
                      return Colors.green[300];
                    case '~':
                      return Colors.orange[300];
                    default:
                      return Colors.red[300];
                  }
                }(),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
              child: Text(tagToCard(tag)),
            ),
          ],
        ),
      ),
    );
  }
}
