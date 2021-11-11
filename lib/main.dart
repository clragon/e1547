import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await initialize();
  runApp(Main());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await settings.initialized;
  await packageInfoInitialized;
}

class Main extends StatelessWidget {
  @override
  Widget build(context) => StartupActions(
        child: ValueListenableBuilder<AppTheme>(
          valueListenable: settings.theme,
          builder: (context, value, child) => ExcludeSemantics(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: defaultUIStyle(appThemeMap[value]!),
              child: MaterialApp(
                title: appInfo.appName,
                theme: appThemeMap[value],
                routes: routes,
                navigatorObservers: [routeObserver],
                scrollBehavior: DesktopDragScrollBehaviour(),
              ),
            ),
          ),
        ),
      );
}
