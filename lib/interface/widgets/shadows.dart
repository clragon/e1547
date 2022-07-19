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
      shadows: const [
        Shadow(
          blurRadius: 9,
        ),
      ],
    );
  }
}

IconData getPlatformBackIcon(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return Icons.arrow_back;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return Icons.arrow_back_ios;
  }
}

class ShadowBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: Navigator.of(context).maybePop,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: ShadowIcon(
        getPlatformBackIcon(context),
        color: Colors.white,
      ),
    );
  }
}
