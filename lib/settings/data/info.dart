import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo extends PackageInfo {
  final String developer;
  final String? github;
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
    super.buildSignature,
  });

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

  List<AppVersion>? _githubData;

  Future<List<AppVersion>?> getVersions() async {
    if (kDebugMode) {
      return null;
    }
    if (_githubData == null) {
      Dio dio = Dio(defaultDioOptions.copyWith(
        baseUrl: 'https://api.github.com/',
      ));
      try {
        List<dynamic> releases = await dio
            .get('repos/$github/releases')
            .then((response) => response.data);
        _githubData = [];
        for (Map release in releases) {
          _githubData!.add(
            AppVersion(
              version: release['tag_name'],
              name: release['name'],
              description: release['body'],
            ),
          );
        }
      } on DioError {
        _githubData = null;
      }
    }
    return _githubData;
  }

  Future<List<AppVersion>?> getNewVersions() async {
    List<AppVersion>? releases = await getVersions();
    if (releases != null) {
      releases = List.from(releases);
      AppVersion current = AppVersion(version: version);
      releases.removeWhere((release) => release.compareTo(current) < 1);
    }
    return releases;
  }
}

class AppVersion extends Comparable<AppVersion> {
  late int major;
  late int minor;
  late int patch;

  String? name;
  String? description;
  String version;

  AppVersion({
    required this.version,
    this.name,
    this.description,
  }) {
    if (version[0] == 'v') {
      version = version.substring(1);
    }
    List<String> parts = version.split('.');
    try {
      major = int.parse(parts[0]);
      minor = int.tryParse(parts[1]) ?? 0;
      patch = int.tryParse(parts[2]) ?? 0;
    } on FormatException {
      major = 0;
      minor = 0;
      patch = 0;
    }
  }

  @override
  int compareTo(AppVersion other) {
    int majorDelta = major.compareTo(other.major);
    if (majorDelta != 0) {
      return majorDelta;
    }
    int minorDelta = minor.compareTo(other.minor);
    if (minorDelta != 0) {
      return minorDelta;
    }
    int patchDelta = patch.compareTo(other.patch);
    if (patchDelta != 0) {
      return patchDelta;
    }
    return 0;
  }
}
