import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pub_semver/pub_semver.dart';

class AppInfoClient {
  AppInfoClient({this.cache}) {
    _dio.interceptors.add(
      ClientCacheInterceptor(options: ClientCacheConfig(store: cache)),
    );
    // logging _after_ cache interceptor to avoid logging cache hits
    _dio.interceptors.add(LoggingDioInterceptor());
  }

  final AppInfo info = AppInfo.instance;
  final CacheStore? cache;
  late final Dio _dio = Dio(
    BaseOptions(
      headers: {
        HttpHeaders.userAgentHeader: info.userAgent,
      },
    ),
  );

  Future<List<AppVersion>> getVersions({bool force = false}) async {
    if (kDebugMode) return [];

    List<dynamic> releases = await _dio
        .get(
          'https://api.github.com/repos/${info.github}/releases',
          options: ClientCacheConfig(
            store: cache,
            policy: force ? CachePolicy.refresh : CachePolicy.request,
          ).toOptions(),
        )
        .then((e) => e.data);
    List<AppVersion> versions = [];
    for (Map<String, dynamic> release in releases) {
      try {
        versions.add(
          AppVersion(
            version: Version.parse(release['tag_name']),
            name: release['name'],
            description: release['body'],
            date: DateTime.parse(release['published_at']),
            binaries: List<String>.from(release['assets']?.map(
              (e) => e['name'].split('.').last,
            )),
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return versions;
  }

  /// Retrieves versions which are newer than the currently installed one.
  ///
  /// If the app was installed via a store,
  /// versions newer than 7 days will be ignored.
  ///
  /// This is because we give the store a chance to automatically update the app.
  Future<List<AppVersion>> getNewVersions({
    bool force = false,
    bool beta = false,
  }) async {
    List<AppVersion> versions = await getVersions(force: force);
    AppVersion current = AppVersion(
        version: Version.parse('${info.version}+${info.buildNumber}'));

    // Remove prior versions
    versions.removeWhere(
      (e) =>
          e.version.compareTo(current.version) < 1 ||
          (!beta && Version.prioritize(e.version, current.version) < 1),
    );

    // Remove versions which do not contain our desired binary
    String? binary;
    if (Platform.isAndroid) {
      binary = 'apk';
    } else if (Platform.isIOS) {
      binary = 'ipa';
    } else if (Platform.isWindows) {
      // enable this when releasing windows
      // binary = 'exe';
    }
    if (binary != null) {
      versions.removeWhere((e) => !(e.binaries?.contains(binary) ?? false));
    }

    // Remove versions newer than 7 days if the app has been installed from a store
    if (info.source.isFromStore) {
      versions.removeWhere((e) =>
          (e.date?.isBefore(
            DateTime.now().subtract(const Duration(days: 7)),
          )) ??
          false);
    }

    return versions;
  }

  /// Returns the latest release URL.
  String latestReleaseUrl() =>
      'https://github.com/${AppInfo.instance.github!}/releases/latest';

  /// Returns donors bundled statically with the app.
  ///
  /// These can be used as a fallback in case the GitHub API is not available.
  Future<List<Donor>> getBundledDonors() async {
    String raw = await rootBundle.loadString('assets/static/donations.json');
    return (json.decode(raw) as List<dynamic>)
        .map((e) => Donor.fromJson(e))
        .toList();
  }

  /// Returns donors from the GitHub repository.
  Future<List<Donor>> getDonors({bool force = false}) async {
    List<dynamic> donors = await _dio
        .get(
          'https://raw.githubusercontent.com/${AppInfo.instance.github}/master/assets/static/donations.json',
          options: ClientCacheConfig(
            store: cache,
            policy: force ? CachePolicy.refresh : CachePolicy.request,
          ).toOptions(),
        )
        .then((e) => jsonDecode(e.data));
    return donors.map((e) => Donor.fromJson(e)).toList();
  }
}

class AppVersion {
  /// Represents an App version with name, description and version number.
  AppVersion({
    required this.version,
    this.name,
    this.description,
    this.date,
    this.binaries,
  });

  /// Name of this version.
  final String? name;

  /// Description of this version.
  final String? description;

  /// The version. Should follow pub.dev semver standards.
  final Version version;

  /// Date of the release.
  final DateTime? date;

  /// List of file extensions of available binaries.
  final List<String>? binaries;
}

typedef AppUpdaterException = DioException;
