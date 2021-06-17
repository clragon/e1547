import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

ValueNotifier<ThemeData> theme = ValueNotifier(appThemeMap[AppTheme.dark]);

Future<void> updateTheme() async {
  theme.value = appThemeMap[await db.theme.value];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  db.theme.addListener(updateTheme);
  await updateTheme();
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StartupActions(
        child: ValueListenableBuilder(
          valueListenable: theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: MaterialApp(
              title: appName,
              theme: value,
              navigatorObservers: [routeObserver],
              routes: routes,
            ),
          ),
        ),
      );
}
