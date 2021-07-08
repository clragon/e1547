import 'package:flutter/material.dart';

class SizedCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double value;

  const SizedCircularProgressIndicator({
    @required this.size,
    this.value,
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
        ),
      ),
    );
  }
}
