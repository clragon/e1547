import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';

import 'app_info.dart';

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

List<AppVersion>? githubData;

Future<List<AppVersion>?> getVersions() async {
  if (kDebugMode) {
    return null;
  }
  if (githubData == null) {
    Dio dio = Dio(defaultDioOptions.copyWith(
      baseUrl: 'https://api.github.com/',
    ));
    try {
      List<dynamic> releases = await dio
          .get('repos/${appInfo.github}/releases')
          .then((response) => response.data);
      githubData = [];
      for (Map release in releases) {
        githubData!.add(
          AppVersion(
            version: release['tag_name'],
            name: release['name'],
            description: release['body'],
          ),
        );
      }
    } on DioError {
      githubData = null;
    }
  }
  return githubData;
}

Future<List<AppVersion>?> getNewVersions() async {
  List<AppVersion>? releases = await getVersions();
  if (releases != null) {
    releases = List.from(releases);
    AppVersion current = AppVersion(version: appInfo.version);
    releases.removeWhere((release) => release.compareTo(current) < 1);
  }
  return releases;
}
