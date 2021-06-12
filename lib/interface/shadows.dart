import 'dart:ui';

import 'package:flutter/material.dart';

class IconShadow extends StatelessWidget {
  final Icon icon;
  final bool showShadow;
  final Color shadowColor;

  final double opacity1 = 0.2;
  final double opacity2 = 0.06;
  final double opacity3 = 0.01;
  final double position1 = 1.0;
  final double position2 = 2.0;
  final double position3 = 3.0;

  IconShadow({@required this.icon, this.showShadow = true, this.shadowColor});

  List<Widget> getShadows(double position, double opacity) {
    Widget child = IconTheme(
        data: IconThemeData(
          opacity: opacity,
        ),
        child: Icon(icon.icon,
            key: icon.key,
            color: shadowColor ?? icon.color,
            size: icon.size,
            semanticLabel: icon.semanticLabel,
            textDirection: icon.textDirection));

    return [
      Positioned(
        bottom: position,
        right: position,
        child: child,
      ),
      Positioned(
        bottom: position,
        left: position,
        child: child,
      ),
      Positioned(
        top: position,
        left: position,
        child: child,
      ),
      Positioned(
        top: position,
        right: position,
        child: child,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (showShadow) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ...getShadows(position3, opacity3),
          ...getShadows(position2, opacity2),
          ...getShadows(position1, opacity1),
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.9, sigmaY: 0.9),
              child: IconTheme(data: IconThemeData(opacity: 1.0), child: icon),
            ),
          )
        ],
      );
    } else {
      return IconTheme(data: IconThemeData(opacity: 1.0), child: icon);
    }
  }
}
