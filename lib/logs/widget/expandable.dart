import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class LogRecordExpandable extends StatelessWidget {
  const LogRecordExpandable({
    required Key super.key,
    required this.color,
    required this.content,
    this.title,
    this.fullContent,
    this.actions,
    this.expanded = false,
  });

  final Color color;
  final Widget? title;
  final Widget content;
  final Widget? fullContent;
  final List<Widget>? actions;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: Expandables.of(context, key!),
      child: ScrollOnExpand(
        child: ExpandableTheme(
          data: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: color,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: color,
                    ),
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
                      padding: const EdgeInsets.all(10).copyWith(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: color),
                      ),
                      child: ExpandablePanel(
                        collapsed: content,
                        expanded: fullContent ?? content,
                      ),
                    ),
                    if (title != null)
                      Positioned(
                        left: 16,
                        top: -8,
                        right: 0,
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            child: title!,
                          ),
                        ),
                      ),
                    Positioned(
                      right: 8,
                      bottom: -10,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            if (actions != null) ...actions!,
                            if (fullContent != null)
                              Builder(
                                builder: (context) => InkWell(
                                  onTap: ExpandableController.of(context,
                                          required: true)!
                                      .toggle,
                                  child: ExpandableIcon(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
