import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class AppInfo extends PackageInfo {
  /// Represents application information.
  AppInfo({
    required this.developer,
    required this.github,
    required this.discord,
    required this.website,
    required super.appName,
    required super.packageName,
    required super.version,
    required super.buildNumber,
    super.buildSignature,
  });

  /// Creates application information from platform info.
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

  /// Developer of the app.
  final String developer;

  /// Name of the app github (developer/repo, not full link).
  final String? github;

  /// Discord server invite link ID (link id only, not full link).
  final String? discord;

  /// Developer website link (without http/s).
  final String? website;

  /// Cached github version data.
  List<AppVersion>? _githubData;

  /// Retrieves all app versions from github.
  Future<List<AppVersion>?> getVersions() async {
    if (kDebugMode) return null;
    if (_githubData == null) {
      Dio dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.github.com/',
          sendTimeout: 30000,
          connectTimeout: 30000,
        ),
      );
      try {
        List<dynamic> releases =
            await dio.get('repos/$github/releases').then((e) => e.data);
        _githubData = [];
        for (Map release in releases) {
          try {
            _githubData!.add(
              AppVersion(
                name: release['name'],
                description: release['body'],
                version: Version.parse(release['tag_name']),
              ),
            );
          } on FormatException {
            continue;
          }
        }
      } on DioError {
        _githubData = null;
      }
    }
    return _githubData;
  }

  /// Retrieves versions which are newer than the currently installed one.
  Future<List<AppVersion>?> getNewVersions() async {
    List<AppVersion>? releases = await getVersions();
    if (releases != null) {
      releases = List.from(releases);
      AppVersion current;
      try {
        current = AppVersion(version: Version.parse(version));
      } on FormatException {
        return null;
      }
      releases.removeWhere(
        (e) => Version.prioritize(e.version, current.version) < 1,
      );
    }
    return releases;
  }
}

class AppVersion {
  /// Represents an App version with name, description and version number.
  /// Commonly pulled from GitHub.
  AppVersion({
    this.name,
    this.description,
    required this.version,
  });

  /// Name of this version.
  final String? name;

  /// Description of this version.
  final String? description;

  /// The version. Should follow pub.dev semver standards.
  final Version version;
}
