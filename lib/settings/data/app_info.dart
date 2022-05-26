import 'package:package_info_plus/package_info_plus.dart';

late final AppInfo appInfo;

Future<void> initializeAppInfo() async => appInfo = await AppInfo.fromPlatform(
      developer: 'binaryfloof',
      github: 'clragon/e1547',
      discord: 'MRwKGqfmUz',
      website: 'e1547.clynamic.net',
    );

abstract class AppDeveloper {
  String get developer;
  String? get github;
  String? get discord;
}

class AppInfo extends PackageInfo with AppDeveloper {
  @override
  final String developer;
  @override
  final String? github;
  @override
  final String? discord;
  final String? website;

  AppInfo({
    required this.developer,
    required this.github,
    required this.discord,
    required this.website,
    required super.appName,
    required super.packageName,
    required super.version,
    required super.buildNumber,
    String buildSignature = '',
  }) : super(
          buildSignature: buildNumber,
        );

  static Future<AppInfo> fromPlatform({
    required String developer,
    required String? github,
    required String? discord,
    required String? website,
  }) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return AppInfo(
      developer: developer,
      github: github,
      discord: discord,
      website: website,
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }
}
