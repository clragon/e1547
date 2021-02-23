import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void setUIColors(ThemeData theme) {
  FlutterStatusbarcolor.setStatusBarColor(theme.canvasColor);
  FlutterStatusbarcolor.setNavigationBarColor(theme.canvasColor);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(
      theme.brightness == Brightness.dark);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(
      theme.brightness == Brightness.dark);
  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
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
    primaryColor: Colors.grey[900],
    primaryColorLight: Colors.grey[900],
    primaryColorDark: Colors.grey[900],
    indicatorColor: Colors.grey[900],
    canvasColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    dialogBackgroundColor: Colors.grey[850],
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
  ),
  'amoled': ThemeData(
    primaryColor: Colors.black,
    primaryColorLight: Colors.black,
    primaryColorDark: Colors.black,
    indicatorColor: Colors.black,
    canvasColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    cardColor: Color.fromARGB(255, 20, 20, 20),
    accentColor: Colors.deepPurple,
    primaryColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
  ),
  'blue': () {
    Color blueBG = Color.fromARGB(255, 2, 15, 35);
    Color blueFG = Color.fromARGB(255, 21, 47, 86);
    return ThemeData(
      primaryColorBrightness: Brightness.dark,
      brightness: Brightness.dark,
      primaryColor: blueBG,
      primaryColorLight: blueBG,
      primaryColorDark: blueBG,
      indicatorColor: blueBG,
      canvasColor: blueBG,
      cardColor: blueFG,
      dialogBackgroundColor: blueFG,
      accentColor: Colors.blue[900],
    );
  }(),
};
