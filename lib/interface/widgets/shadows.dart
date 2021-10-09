import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class ShadowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const ShadowIcon(this.icon, {this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedIcon(
      icon,
      size: size,
      color: color,
      shadows: getTextShadows(),
    );
  }
}

List<Shadow> getTextShadows() {
  const double blur = 5;
  const double offset = 2;
  const Color color = Colors.black38;

  return [
    Shadow(
      offset: Offset(offset, offset),
      blurRadius: blur,
      color: color,
    ),
    Shadow(
      offset: Offset(-offset, offset),
      blurRadius: blur,
      color: color,
    ),
    Shadow(
      offset: Offset(-offset, -offset),
      blurRadius: blur,
      color: color,
    ),
    Shadow(
      offset: Offset(offset, -offset),
      blurRadius: blur,
      color: color,
    ),
  ];
}
