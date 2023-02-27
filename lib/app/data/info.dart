import 'package:e1547/settings/settings.dart';

export 'package:e1547/settings/settings.dart' show AppInfo;

/// Creates a default AppInfo with the correct, global app info.
Future<AppInfo> initializeAppInfo() async => AppInfo.fromPlatform(
      developer: 'binaryfloof',
      github: 'clragon/e1547',
      discord: 'MRwKGqfmUz',
      website: 'e1547.clynamic.net',
      kofi: 'binaryfloof',
      allowedHosts: ['e926.net', 'e621.net'],
    );
