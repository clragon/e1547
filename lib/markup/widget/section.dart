import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class SectionWrap extends StatelessWidget {
  const SectionWrap({
    required Key super.key,
    required this.child,
    this.title,
    this.expanded = false,
  });

  final Widget child;
  final String? title;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return IndentedCard(
      backgroundColor: Theme.of(context).canvasColor,
      color: dimTextColor(context),
      child: ExpandablePanel(
        controller: Expandables.of(context, key!, expanded: expanded),
        header: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title?.replaceAll('\n', 'replace') ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        collapsed: const SizedBox.shrink(),
        expanded: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [child],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
