import 'package:flutter/material.dart';

class ColoredCard extends StatelessWidget {
  const ColoredCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.color,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.leading,
    this.trailing,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color case final stripeColor?)
              Container(
                height: 27,
                decoration: BoxDecoration(
                  color: stripeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: leading ?? const SizedBox(width: 5),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                  right: 10,
                  left: 6,
                ),
                child: child,
              ),
            ),
            if (trailing case final trailing?) trailing,
          ],
        ),
      ),
    );
  }
}

class IndentedCard extends StatelessWidget {
  const IndentedCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.color,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Padding(padding: const EdgeInsets.only(left: 5), child: child),
          if (color != null)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
