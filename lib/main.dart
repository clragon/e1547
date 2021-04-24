import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ValueNotifier<ThemeData> _theme = ValueNotifier(themeMap['dark']);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  _theme.value = themeMap[await db.theme.value];
  db.theme
      .addListener(() async => _theme.value = themeMap[await db.theme.value]);
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initUser(context: context);
    return ValueListenableBuilder(
      valueListenable: _theme,
      builder: (context, value, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: value.canvasColor,
          systemNavigationBarIconBrightness:
              value.brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
        child: MaterialApp(
          title: appName,
          theme: value,
          navigatorObservers: [routeObserver],
          routes: routes,
        ),
      ),
    );
  }
}
