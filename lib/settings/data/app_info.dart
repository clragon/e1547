import 'package:package_info_plus/package_info_plus.dart';

late final AppInfo appInfo;

Future<void> initializeAppInfo() async => appInfo = await AppInfo.fromPlatform(
      developer: 'binaryfloof',
      github: 'clragon/e1547',
      discord: 'MRwKGqfmUz',
    );

abstract class AppDeveloper {
  String get developer;
  String? get github;
  String? get discord;
}

class AppInfo extends PackageInfo with AppDeveloper {
  final String developer;
  final String? github;
  final String? discord;

  AppInfo({
    required this.developer,
    required this.github,
    required this.discord,
    required String appName,
    required String packageName,
    required String version,
    required String buildNumber,
    String buildSignature = '',
  }) : super(
          appName: appName,
          packageName: packageName,
          version: version,
          buildNumber: buildNumber,
          buildSignature: buildNumber,
        );

  static Future<AppInfo> fromPlatform({
    required String developer,
    required String github,
    required String discord,
  }) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return AppInfo(
      developer: developer,
      github: github,
      discord: discord,
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }
}
