import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';

class TimedText extends StatelessWidget {
  const TimedText({
    super.key,
    required this.child,
    required this.created,
    this.updated,
  });

  final Widget child;
  final DateTime created;
  final DateTime? updated;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Flexible(child: child),
        Text(
          ' • ${created.relativeTime(context)}'
          '${updated != null && updated!.isAfter(created) ? ' (edited)' : ''}',
          maxLines: 1,
          style: TextStyle(fontSize: 12, color: dimTextColor(context)),
        ),
      ],
    );
  }
}
