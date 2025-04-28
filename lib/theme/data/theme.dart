import 'package:e1547/theme/data/animation.dart';
import 'package:flutter/material.dart';

enum AppTheme {
  dark,
  amoled,
  light,
  blue,
  system;

  ThemeData get data => switch (this) {
        light => ThemeData.light().prepare(),
        dark => ThemeData.dark().map((theme) => theme).prepare(),
        amoled => ThemeData.dark().prepare(),
        blue => ThemeData.dark().prepare(),
        AppTheme.system => switch (
              WidgetsBinding.instance.platformDispatcher.platformBrightness) {
            Brightness.light => AppTheme.light.data,
            Brightness.dark => AppTheme.dark.data,
          },
      };
}

extension ColorBrightnessExtension on Color {
  Color shiftBrightness(double amount) {
    final hsl = HSLColor.fromColor(this);
    final adjusted = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return adjusted.toColor();
  }
}

ColorScheme generateColorScheme({
  required Brightness brightness,
  required Color primary,
  required Color background,
  required Color surface,
  required Color text,
  required Color error,
}) {
  final bool isDark = brightness == Brightness.dark;
  double shift(double v) => isDark ? v : -v;

  return ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: text,
    primaryContainer: primary.shiftBrightness(shift(0.2)),
    onPrimaryContainer: text,
    secondary: surface.shiftBrightness(shift(0.15)),
    onSecondary: text,
    secondaryContainer: surface.shiftBrightness(shift(0.05)),
    onSecondaryContainer: text,
    tertiary: primary.shiftBrightness(shift(0.25)),
    onTertiary: text,
    tertiaryContainer: primary.shiftBrightness(shift(0.35)),
    onTertiaryContainer: text,
    error: error,
    onError: brightness == Brightness.dark ? Colors.black : Colors.white,
    errorContainer: error.shiftBrightness(shift(0.2)),
    onErrorContainer:
        brightness == Brightness.dark ? Colors.white : Colors.black,
    surface: surface,
    onSurface: text,
    surfaceDim: surface.shiftBrightness(shift(0.05)),
    surfaceBright: surface.shiftBrightness(shift(0.15)),
    surfaceContainerLowest: surface.shiftBrightness(shift(0.1)),
    surfaceContainerLow: surface.shiftBrightness(shift(0.08)),
    surfaceContainer: surface.shiftBrightness(shift(0.05)),
    surfaceContainerHigh: surface.shiftBrightness(shift(0.02)),
    surfaceContainerHighest: surface,
    onSurfaceVariant: text.withAlpha(179),
    outline: text.withAlpha(102),
    outlineVariant: text.withAlpha(51),
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: background,
    onInverseSurface: text,
    inversePrimary: primary,
    surfaceTint: primary,
  );
}

extension on ThemeData {
  ThemeData map(ThemeData Function(ThemeData theme) call) => call(this);

  ThemeData prepare() => copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          },
        ),
        appBarTheme: appBarTheme.copyWith(
          surfaceTintColor: Colors.transparent,
        ),
        extensions: [
          const AnimationTheme(),
        ],
      );
}
