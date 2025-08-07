import 'dart:io';

import 'package:e1547/about/about.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/foundation.dart';
import 'package:pub_semver/pub_semver.dart';

class AboutRepo {
  AboutRepo({required this.persona, required this.client});

  final Persona persona;
  final AboutClient client;
  final About about = About.instance;

  Future<List<T>> _emptyInDebug<T>(Future<List<T>> Function() fetch) {
    if (kDebugMode) return Future.value([]);
    return fetch();
  }

  Future<List<AppVersion>> versions({bool force = false}) =>
      _emptyInDebug(() => client.versions(force: force));

  /// Retrieves versions which are newer than the currently installed one.
  ///
  /// If the app was installed via a store,
  /// versions newer than 7 days will be ignored.
  ///
  /// This is because we give the store a chance to automatically update the app.
  Future<List<AppVersion>> newVersions({
    bool force = false,
    bool beta = false,
  }) => _emptyInDebug(
    () => client.versions(force: force).map((versions) {
      AppVersion current = AppVersion(
        version: Version.parse('${about.version}+${about.buildNumber}'),
      );

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
      if (about.source.isFromStore) {
        versions.removeWhere(
          (e) =>
              (e.date?.isBefore(
                DateTime.now().subtract(const Duration(days: 7)),
              )) ??
              false,
        );
      }

      return versions;
    }),
  );

  String latestReleaseUrl() => client.latestReleaseUrl();

  Future<List<Donor>> bundledDonors() => client.bundledDonors();

  Future<List<Donor>> donors({bool force = false}) =>
      _emptyInDebug(() => client.donors(force: force));
}
