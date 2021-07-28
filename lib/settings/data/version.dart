import 'package:dio/dio.dart';
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
      major = int.tryParse(parts[0])!;
      minor = int.tryParse(parts[1]) ?? 0;
      patch = int.tryParse(parts[2]) ?? 0;
    } catch (_) {
      major = 0;
      minor = 0;
      patch = 0;
    }
  }

  @override
  int compareTo(AppVersion other) {
    int majorDelta = this.major.compareTo(other.major);
    if (majorDelta != 0) {
      return majorDelta;
    }
    int minorDelta = this.minor.compareTo(other.minor);
    if (minorDelta != 0) {
      return minorDelta;
    }
    int patchDelta = this.patch.compareTo(other.patch);
    if (patchDelta != 0) {
      return patchDelta;
    }
    return 0;
  }
}

Future<List<AppVersion>> getNewVersions() async {
  List<AppVersion> releases = await getVersions();
  AppVersion current = AppVersion(version: appVersion);
  return releases
      .where((AppVersion release) => release.compareTo(current) == 1)
      .toList();
}

List<AppVersion> githubData = [];

Future<List<AppVersion>> getVersions() async {
  if (kReleaseMode) {
    if (githubData.isEmpty) {
      Dio dio = Dio(BaseOptions(
        baseUrl: 'https://api.github.com/',
        sendTimeout: 30000,
        connectTimeout: 30000,
      ));
      try {
        dio.get('repos/$github/releases').then(
          (response) {
            for (Map release in response.data) {
              githubData.add(
                AppVersion(
                    version: release['tag_name'],
                    name: release['name'],
                    description: release['body']),
              );
            }
          },
        );
      } on DioError {
        // failed to get github data
      }
    }
  }
  return githubData;
}
