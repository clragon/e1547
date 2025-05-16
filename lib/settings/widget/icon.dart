import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? const Color(0xFF131313)
                : null,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      width: radius * 2,
      height: radius * 2,
      child: Image.asset('assets/icon/app/inapp.png'),
    );
  }
}
