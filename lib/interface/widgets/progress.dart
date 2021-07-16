import 'package:flutter/material.dart';

class SizedCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double value;
  final double strokeWidth;

  const SizedCircularProgressIndicator({
    @required this.size,
    this.value,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
