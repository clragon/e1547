import 'package:flutter/material.dart';

class QuoteWrap extends StatelessWidget {
  final Widget child;

  const QuoteWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).canvasColor,
      child: Padding(
        padding: EdgeInsets.all(8),
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
    );
  }
}
