import 'package:e1547/settings/settings.dart';

typedef AppInitBundle = ({SettingsService settings});

Future<AppInitBundle> initApp() async {
  return (settings: await SettingsService.init(),);
}
