import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

class ShadowIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const ShadowIcon(this.icon, {this.size = 24});

  @override
  Widget build(BuildContext context) {
    return DecoratedIcon(
      icon,
      size: size,
      shadows: getTextShadows(),
    );
  }
}

List<Shadow> getTextShadows() {
  final double blur = 5;
  final double offset = 2;
  final Color color = Colors.black38;

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
