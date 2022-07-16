import 'package:e1547/settings/settings.dart';

Future<AppInfo> initializeAppInfo() async => AppInfo.fromPlatform(
      developer: 'binaryfloof',
      github: 'clragon/e1547',
      discord: 'MRwKGqfmUz',
      website: 'e1547.clynamic.net',
    );
