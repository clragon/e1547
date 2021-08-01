import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ValueNotifier<ThemeData> theme = ValueNotifier(appThemeMap[AppTheme.dark]!);

Future<void> updateTheme() async {
  theme.value = appThemeMap[await settings.theme.value]!;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  settings.theme.addListener(updateTheme);
  await updateTheme();
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StartupActions(
        child: ValueListenableBuilder(
          valueListenable: theme,
          builder: (context, ThemeData value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: defaultUIStyle(theme.value),
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
