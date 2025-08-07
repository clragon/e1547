import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_checker/store_checker.dart';

export 'package:store_checker/store_checker.dart' show Source;

/// Represents constant global application configuration.
final class About extends PackageInfo {
  About._({
    required this.developer,
    required this.github,
    required this.discord,
    required this.website,
    required this.kofi,
    required this.email,
    required this.source,
    required super.appName,
    required super.packageName,
    required super.version,
    required super.buildNumber,
    super.buildSignature,
  });

  /// Creates application information from platform info.
  static Future<void> initializePlatform({
    required String developer,
    required String? github,
    required String? discord,
    required String? website,
    required String? kofi,
    required String? email,
  }) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    Source source = await Future(() {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return Source.UNKNOWN;
      }
      return StoreChecker.getSource;
    });
    _instance = About._(
      developer: developer,
      github: github,
      discord: discord,
      website: website,
      kofi: kofi,
      email: email,
      source: source,
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }

  static Future<void> initializeMock({
    required String developer,
    required String? github,
    required String? discord,
    required String? website,
    required String? kofi,
    required String? email,
    required String appName,
    required String packageName,
    required String version,
    required String buildNumber,
    String buildSignature = '',
    Source source = Source.UNKNOWN,
  }) async => _instance = About._(
    developer: developer,
    github: github,
    discord: discord,
    website: website,
    kofi: kofi,
    email: email,
    source: source,
    appName: appName,
    packageName: packageName,
    version: version,
    buildNumber: buildNumber,
    buildSignature: buildSignature,
  );

  static About? _instance;
  static About get instance {
    if (_instance == null) {
      throw StateError('About has not been initialized');
    }
    return _instance!;
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

  /// Developer email.
  final String? email;

  /// Source of installation.
  final Source source;

  /// User agent for HTTP requests.
  String get userAgent => '$appName/$version ($developer)';
}

extension StoreSource on Source {
  bool get isFromStore => ![
    Source.IS_INSTALLED_FROM_LOCAL_SOURCE,
    Source.IS_INSTALLED_FROM_OTHER_SOURCE,
    Source.UNKNOWN,
  ].contains(this);
}
