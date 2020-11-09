import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class SectionWrap extends StatelessWidget {
  final Widget child;
  final String title;
  final bool expanded;

  const SectionWrap(
      {@required this.child, @required this.title, this.expanded});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).canvasColor,
        child: ExpandableNotifier(
          initialExpanded: expanded,
          child: ExpandableTheme(
            data: ExpandableThemeData(
              iconColor: Theme.of(context).iconTheme.color,
            ),
            child: ExpandablePanel(
              header: Padding(
                padding: EdgeInsets.only(left: 8, top: 10),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              collapsed: Container(),
              expanded: Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [child],
                ),
              ),
            ),
          ),
        ));
  }
}
