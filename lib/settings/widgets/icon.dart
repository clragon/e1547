import 'package:flutter/widgets.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      width: radius * 2,
      height: radius * 2,
      child: Image.asset('assets/icon/app/round.png'),
    );
  }
}
