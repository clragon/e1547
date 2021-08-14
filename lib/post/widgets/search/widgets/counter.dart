import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DrawerCounter extends StatefulWidget {
  final PostController controller;

  const DrawerCounter({required this.controller});

  @override
  _DrawerCounterState createState() => _DrawerCounterState();
}

class _DrawerCounterState extends State<DrawerCounter> with LinkingMixin {
  final int limit = 15;
  List<Widget>? children;

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        widget.controller: updateTags,
      };

  Future<void> updateTags() async {
    if (mounted) {
      setState(() {
        children = null;
      });
    }

    if (widget.controller.value.status == PagingStatus.loadingFirstPage) {
      return;
    }
    List<CountedTag> counts = countTagsByPosts(widget.controller.itemList!);
    counts.sort((a, b) => b.count.compareTo(a.count));

    List<Widget> cards = [];
    for (CountedTag tag in counts.take(limit)) {
      cards.add(TagCounterCard(
        tag: tag.tag,
        count: tag.count,
        category: tag.category,
        controller: widget.controller,
      ));
    }

    if (mounted) {
      setState(() {
        children = cards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandableNotifier(
          initialExpanded: false,
          child: ExpandableTheme(
            data: ExpandableThemeData(
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              iconColor: Theme.of(context).iconTheme.color,
            ),
            child: ExpandablePanel(
              header: ListTile(
                title: Text(
                  'Tags',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: null,
                leading: Icon(Icons.tag),
              ),
              expanded: Column(
                children: [
                  Divider(),
                  SafeCrossFade(
                    showChild: children != null,
                    builder: (context) => Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: children!,
                            ),
                          )
                        ],
                      ),
                    ),
                    secondChild: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedCircularProgressIndicator(size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              collapsed: SizedBox.shrink(),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
