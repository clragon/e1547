import 'package:flutter/material.dart';

double smallIconSize(BuildContext context) => 18;

Color dimTextColor(BuildContext context, [double opacity = 0.35]) => Theme.of(
  context,
).textTheme.bodyMedium!.color!.withAlpha((opacity * 255).ceil());

class Dimmed extends StatelessWidget {
  const Dimmed({super.key, required this.child, this.opacity = 0.35});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(
        context,
      ).iconTheme.copyWith(color: dimTextColor(context, opacity)),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dimTextColor(context, opacity)),
        child: child,
      ),
    );
  }
}
