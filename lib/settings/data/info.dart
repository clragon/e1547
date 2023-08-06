import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:store_checker/store_checker.dart';

class AppInfo extends PackageInfo {
  /// Represents constant global application configuration.
  AppInfo({
    required this.developer,
    required this.github,
    required this.discord,
    required this.website,
    required this.kofi,
    required this.allowedHosts,
    required this.source,
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
    required String? kofi,
    required List<String> allowedHosts,
  }) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    Source source = await Future(() {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return Source.UNKNOWN;
      }
      return StoreChecker.getSource;
    });
    return AppInfo(
      developer: developer,
      github: github,
      discord: discord,
      website: website,
      kofi: kofi,
      allowedHosts: allowedHosts,
      source: source,
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }

  /// Developer of the app.
  final String developer;

  /// Name of the app github (developer/repo).
  final String? github;

  /// Discord server invite link ID (id only).
  final String? discord;

  /// Developer website link (without http/s).
  final String? website;

  /// Developer ko-fi username.
  final String? kofi;

  /// Source of installation.
  final Source source;

  /// List of allow hosts for the app.
  /// The first entry is used as default.
  final List<String> allowedHosts;

  String get userAgent => '$appName/$version ($developer)';

  /// Retrieves all app versions from github.
  /// This call is expensive. Provide a cache when possible!
  Future<List<AppVersion>> getVersions({
    CacheStore? cache,
    bool force = false,
  }) async {
    // We do not want to exhaust the GitHub API during testing
    if (kDebugMode) return [];
    Dio dio = Dio(
      BaseOptions(headers: {HttpHeaders.userAgentHeader: userAgent}),
    );
    dio.interceptors.add(LoggyDioInterceptor(
      requestLevel: LogLevel.debug,
      responseLevel: LogLevel.debug,
      errorLevel: LogLevel.warning,
    ));
    dio.interceptors.add(
      ClientCacheInterceptor(options: ClientCacheConfig(store: cache)),
    );
    List<dynamic> releases = await dio
        .get(
          'https://api.github.com/repos/$github/releases',
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
  /// This call is expensive. Provide a cache when possible!
  Future<List<AppVersion>> getNewVersions({
    CacheStore? cache,
    bool force = false,
    bool beta = false,
  }) async {
    List<AppVersion> versions = await getVersions(cache: cache, force: force);
    AppVersion current =
        AppVersion(version: Version.parse('$version+$buildNumber'));

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
    if (source.isFromStore) {
      versions.removeWhere((e) =>
          (e.date?.isBefore(
            DateTime.now().subtract(const Duration(days: 7)),
          )) ??
          false);
    }

    return versions;
  }
}

class AppVersion {
  /// Represents an App version with name, description and version number.
  /// Commonly pulled from GitHub.
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

typedef AppInfoClientException = DioException;

extension StoreSource on Source {
  bool get isFromStore => ![
        Source.IS_INSTALLED_FROM_LOCAL_SOURCE,
        Source.IS_INSTALLED_FROM_OTHER_SOURCE,
        Source.UNKNOWN,
      ].contains(this);
}
