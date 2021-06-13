import 'package:e1547/interface.dart';
import 'package:e1547/interface/startup.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ValueNotifier<ThemeData> theme = ValueNotifier(appThemeMap[AppTheme.dark]);

Future<void> updateTheme() async {
  theme.value = appThemeMap[await db.theme.value];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  db.theme.addListener(updateTheme);
  updateTheme();
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StartupActions(
        child: ValueListenableBuilder(
          valueListenable: theme,
          builder: (context, value, child) =>
              AnnotatedRegion<SystemUiOverlayStyle>(
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
            child: ExcludeSemantics(
              child: MaterialApp(
                title: appName,
                theme: value,
                navigatorObservers: [routeObserver],
                routes: routes,
              ),
            ),
          ),
        ),
      );
}
