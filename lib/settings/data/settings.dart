import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';

class Settings extends NotifiedSettings {
  Settings(super.preferences);

  static Future<Settings> getInstance() async =>
      Settings(await SharedPreferences.getInstance());

  @Deprecated('Credentials are now stored in the identity database')
  late final ValueNotifier<Credentials?> credentials = createJsonSetting(
    key: 'credentials',
    initialValue: null,
    fromJson: Credentials.fromJson,
  );

  late final ValueNotifier<int> identity = createSetting(
    key: 'identity',
    initialValue: 1,
  );

  late final ValueNotifier<AppTheme> theme = createEnumSetting(
    key: 'theme',
    initialValue: AppTheme.values.first,
    values: AppTheme.values,
  );

  late final ValueNotifier<bool> writeHistory =
      createSetting(key: 'writeHistory', initialValue: true);
  late final ValueNotifier<bool> trimHistory =
      createSetting(key: 'trimHistory', initialValue: false);

  late final ValueNotifier<int> tileSize =
      createSetting(key: 'tileSize', initialValue: 200);
  late final ValueNotifier<GridQuilt> quilt = createEnumSetting(
    key: 'quilt',
    initialValue: GridQuilt.square,
    values: GridQuilt.values,
  );

  late final ValueNotifier<bool> filterUnseenFollows =
      createSetting(key: 'filterUnseenFollows', initialValue: false);
  late final ValueNotifier<bool> showPostInfo =
      createSetting<bool>(key: 'showPostInfo', initialValue: false);
  late final ValueNotifier<bool> showBeta =
      createSetting<bool>(key: 'showBeta', initialValue: false);
  late final ValueNotifier<bool> upvoteFavs =
      createSetting<bool>(key: 'upvoteFavs', initialValue: false);
  late final ValueNotifier<String> downloadPath = createSetting<String>(
    key: 'downloadPath',
    initialValue: Uri(
      scheme: 'content',
      host: 'com.android.externalstorage.documents',
      path: '/tree/primary${Uri.encodeComponent(':Pictures')}',
    ).toString(),
    read: (prefs, key) {
      String? result = prefs.getString(key);
      if (result != null) {
        Uri uri = Uri.parse(result);
        if (uri.host.isEmpty) {
          return null;
        }
      }
      return result;
    },
  );
  late final ValueNotifier<bool> muteVideos =
      createSetting<bool>(key: 'muteVideos', initialValue: true);

  late final ValueNotifier<bool> secureDisplay =
      createSetting<bool>(key: 'secureDisplay', initialValue: false);
  late final ValueNotifier<String?> appPin =
      createSetting(key: 'appPin', initialValue: null);
  late final ValueNotifier<bool> biometricAuth =
      createSetting<bool>(key: 'biometricAuth', initialValue: false);
}
