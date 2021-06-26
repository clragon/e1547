import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class DrawerCounter extends StatefulWidget {
  final PostProvider provider;

  const DrawerCounter({@required this.provider});

  @override
  _DrawerCounterState createState() => _DrawerCounterState();
}

class _DrawerCounterState extends State<DrawerCounter> {
  final int limit = 15;
  List<Widget> children;

  Future<void> updateTags() async {
    setState(() {
      children = null;
    });

    if (widget.provider.isLoading) {
      return;
    }
    List<CountedTag> counts = countTagsByPosts(widget.provider.posts.value);
    counts.sort((a, b) => b.count.compareTo(a.count));

    List<Widget> cards = [];
    for (CountedTag tag in counts.take(limit)) {
      cards.add(TagCounterCard(
        tag: tag.tag,
        count: tag.count,
        category: tag.category,
        provider: widget.provider,
      ));
    }

    setState(() {
      children = cards;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(updateTags);
    updateTags();
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.posts.removeListener(updateTags);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: children,
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
      ),
    );
  }
}
