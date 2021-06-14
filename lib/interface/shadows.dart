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
      shadows: [
        Shadow(
          blurRadius: 4,
          color: Colors.black,
        ),
      ],
    );
  }
}

List<Shadow> getTextShadows() {
  final double blur = 3;
  final double offset = 3.0;

  return [
    Shadow(
      offset: Offset(offset, offset),
      blurRadius: blur,
      color: Colors.black,
    ),
    Shadow(
      offset: Offset(-offset, offset),
      blurRadius: blur,
      color: Colors.black,
    ),
    Shadow(
      offset: Offset(-offset, -offset),
      blurRadius: blur,
      color: Colors.black,
    ),
    Shadow(
      offset: Offset(offset, -offset),
      blurRadius: blur,
      color: Colors.black,
    ),
  ];
}
