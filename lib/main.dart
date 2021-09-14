import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.initialized;
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(context) => StartupActions(
        child: ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiMode>(
              value: SystemUiMode.edgeToEdge,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: defaultUIStyle(appThemeMap[value]!),
                child: MaterialApp(
                  title: appName,
                  theme: appThemeMap[value],
                  routes: routes,
                  navigatorObservers: [routeObserver],
                  scrollBehavior: DesktopDragScrollBehaviour(),
                ),
              ),
            ),
          ),
        ),
      );
}
