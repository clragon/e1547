import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppTheme {
  light,
  dark,
  amoled,
  blue,
}

SystemUiOverlayStyle defaultUIStyle(ThemeData theme) => SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: theme.canvasColor,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );

ThemeData prepareTheme(ThemeData theme) => theme.copyWith(
      applyElevationOverlayColor: false,
      dialogBackgroundColor: theme.canvasColor,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.accentColor
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
        backwardsCompatibility: false,
      ),
    );

final Map<AppTheme, ThemeData> appThemeMap = {
  AppTheme.light: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue,
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
        primarySwatch: Colors.teal,
        accentColor: Colors.tealAccent,
        cardColor: Colors.grey[850],
        backgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.amoled: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
        cardColor: Color.fromARGB(255, 20, 20, 20),
        backgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.blue: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.indigo,
        accentColor: Colors.indigoAccent,
        cardColor: Color.fromARGB(255, 21, 47, 86),
        backgroundColor: Color.fromARGB(255, 2, 15, 35),
        brightness: Brightness.dark,
      ),
    ),
  ),
};
