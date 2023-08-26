import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class QuoteWrap extends StatelessWidget {
  const QuoteWrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StripedCard(
      backgroundColor: Theme.of(context).canvasColor,
      color: dimTextColor(context),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [child],
        ),
      ),
    );
  }
}
