import 'package:flutter/material.dart';

enum AppTheme {
  light,
  dark,
  amoled,
  blue,
}

final Map<AppTheme, ThemeData> appThemeMap = {
  AppTheme.light: ThemeData(
    canvasColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      color: Colors.grey[50],
    ),
    dialogBackgroundColor: Colors.grey[50],
    primaryColorBrightness: Brightness.light,
    brightness: Brightness.light,
  ),
  AppTheme.dark: ThemeData(
    canvasColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    dialogBackgroundColor: Colors.grey[850],
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      accentColor: Colors.tealAccent,
      brightness: Brightness.dark,
    ),
  ),
  AppTheme.amoled: ThemeData(
    canvasColor: Colors.black,
    cardColor: Color.fromARGB(255, 20, 20, 20),
    dialogBackgroundColor: Colors.black,
    brightness: Brightness.dark,
    accentColor: Colors.deepPurple,
    accentColorBrightness: Brightness.dark,
    primaryColor: Colors.black,
    primaryColorBrightness: Brightness.dark,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.deepPurpleAccent;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.deepPurple;
        }
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.deepPurple;
      }
      return null;
    })),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: Colors.deepPurpleAccent,
      cardColor: Color.fromARGB(255, 20, 20, 20),
      backgroundColor: Colors.black,
      brightness: Brightness.dark,
    ),
  ),
  AppTheme.blue: () {
    Color blueBG = Color.fromARGB(255, 2, 15, 35);
    Color blueFG = Color.fromARGB(255, 21, 47, 86);
    return ThemeData(
      canvasColor: blueBG,
      cardColor: blueFG,
      dialogBackgroundColor: blueFG,
      brightness: Brightness.dark,
      accentColor: Colors.indigo,
      accentColorBrightness: Brightness.dark,
      primaryColor: blueBG,
      primaryColorBrightness: Brightness.dark,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.indigoAccent;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.indigo;
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.indigo;
        }
        return null;
      })),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.indigo,
        accentColor: Colors.indigoAccent,
        cardColor: blueFG,
        backgroundColor: blueBG,
        brightness: Brightness.dark,
      ),
    );
  }(),
};
