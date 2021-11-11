import 'package:package_info_plus/package_info_plus.dart';

late AppInfo appInfo;

Future<void> packageInfoInitialized =
    AppInfo.fromPlatform().then((value) => appInfo = value);

class AppInfo extends PackageInfo {
  final String developer = 'binaryfloof';
  final String github = 'clragon/e1547';
  final String discord = 'MRwKGqfmUz';

  AppInfo({
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

  static Future<AppInfo> fromPlatform() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return AppInfo(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }
}
