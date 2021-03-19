import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

Future<void> setUIColors(ThemeData theme) async {
  await FlutterStatusbarcolor.setStatusBarColor(theme.canvasColor);
  await FlutterStatusbarcolor.setNavigationBarColor(theme.canvasColor);
  await FlutterStatusbarcolor.setNavigationBarWhiteForeground(
      theme.brightness == Brightness.dark);
  await FlutterStatusbarcolor.setStatusBarWhiteForeground(
      theme.brightness == Brightness.dark);
  await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
}

final Map<String, ThemeData> themeMap = {
  'light': ThemeData(
    canvasColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
    ),
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    primaryColorBrightness: Brightness.light,
    brightness: Brightness.light,
  ),
  'dark': ThemeData(
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
  'amoled': ThemeData(
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
  'blue': () {
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
