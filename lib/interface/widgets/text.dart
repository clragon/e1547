import 'package:flutter/material.dart';
import 'package:relative_time/relative_time.dart';

Color dimTextColor(BuildContext context, [double opacity = 0.35]) =>
    Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(opacity);

double smallIconSize(BuildContext context) => 18;

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
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Flexible(child: child),
        Text(
          ' • ${created.relativeTime(context)}'
          '${updated != null && updated!.isAfter(created) ? ' (edited)' : ''}',
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            color: dimTextColor(context),
          ),
        ),
      ],
    );
  }
}

class DimSubtree extends StatelessWidget {
  const DimSubtree({super.key, required this.child, this.opacity = 0.35});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(
            color: dimTextColor(context, opacity),
            size: smallIconSize(context),
          ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: dimTextColor(context, opacity),
            ),
        child: child,
      ),
    );
  }
}
