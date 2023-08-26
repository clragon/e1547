import 'package:flutter/material.dart';

class StripedCard extends StatelessWidget {
  const StripedCard({
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
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: child,
          ),
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
