import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class SectionWrap extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool expanded;

  const SectionWrap({required this.child, this.title, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).canvasColor,
      child: ExpandableNotifier(
        initialExpanded: expanded,
        child: ExpandableTheme(
          data: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: Theme.of(context).iconTheme.color,
          ),
          child: ExpandablePanel(
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                title?.replaceAllMapped(RegExp(r'\n'), (_) => '') ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            collapsed: SizedBox.shrink(),
            expanded: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [child],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
