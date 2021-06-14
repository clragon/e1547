import 'package:flutter/material.dart';

class FakeCard extends StatelessWidget {
  final Widget child;

  const FakeCard({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: child,
      ),
    );
  }
}
