import 'package:flutter/material.dart';

extension DesktopTargetPlatform on ThemeData {
  bool get isDesktop {
    return [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ].contains(platform);
  }
}
