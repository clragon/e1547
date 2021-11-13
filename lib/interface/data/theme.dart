import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppTheme {
  light,
  dark,
  amoled,
  blue,
}

final MaterialColor primarySwatch = MaterialColor(
  0xFFFCB328,
  <int, Color>{
    50: Color(0xFFFFF6E5),
    100: Color(0xFFFEE8BF),
    200: Color(0xFFFED994),
    300: Color(0xFFFDCA69),
    400: Color(0xFFFCBE48),
    500: Color(0xFFFCB328),
    600: Color(0xFFFCAC24),
    700: Color(0xFFFBA31E),
    800: Color(0xFFFB9A18),
    900: Color(0xFFFA8B0F),
  },
);

final Color accent = Color(0xFFffc107);

SystemUiOverlayStyle defaultUIStyle(ThemeData theme) => SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: theme.brightness,
      statusBarIconBrightness: theme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );

ThemeData prepareTheme(ThemeData theme) => theme.copyWith(
      platform: theme.platform == TargetPlatform.windows
          ? TargetPlatform.android
          : theme.platform,
      applyElevationOverlayColor: false,
      dialogBackgroundColor: theme.canvasColor,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.secondary
              : null,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.primary.withOpacity(0.5)
              : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.primary
              : null,
        ),
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: defaultUIStyle(theme),
        color: theme.canvasColor,
        foregroundColor: theme.iconTheme.color,
      ),
    );

final Map<AppTheme, ThemeData> appThemeMap = {
  AppTheme.light: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: accent,
        cardColor: Colors.white,
        backgroundColor: Colors.grey[50],
        brightness: Brightness.light,
      ),
    ),
  ).copyWith(
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
  ),
  AppTheme.dark: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: accent,
        cardColor: Colors.grey[900],
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.amoled: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: accent,
        cardColor: Color.fromARGB(255, 20, 20, 20),
        backgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.blue: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: accent,
        cardColor: Color.fromARGB(255, 31, 60, 103),
        backgroundColor: Color.fromARGB(255, 15, 33, 60),
        brightness: Brightness.dark,
      ),
    ),
  ),
};

class DesktopDragScrollBehaviour extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
