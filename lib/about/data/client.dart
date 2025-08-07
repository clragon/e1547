import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/about/about.dart';

import 'package:e1547/stream/stream.dart';
import 'package:flutter/services.dart';
import 'package:pub_semver/pub_semver.dart';

class AboutClient {
  AboutClient({
    required this.dio,
    required this.versionCache,
    required this.donorCache,
  });

  final Dio dio;
  final PagedValueCache<QueryKey, int, AppVersion> versionCache;
  final PagedValueCache<QueryKey, int, Donor> donorCache;
  final About about = About.instance;

  Future<List<AppVersion>> versions({bool force = false}) => versionCache
      .stream(
        QueryKey(const ['app_versions']),
        fetch: () => dio
            .get('https://api.github.com/repos/${about.github}/releases')
            .then((response) {
              try {
                return pick(response.data).asListOrEmpty(
                  (e) => pick(e.asMapOrThrow()).letOrThrow(
                    (e) => AppVersion(
                      version: Version.parse(e('tag_name').asStringOrThrow()),
                      name: e('name').asStringOrThrow(),
                      description: e('body').asStringOrThrow(),
                      date: e('published_at').asDateTimeOrThrow(),
                      binaries: e('assets').asListOrEmpty(
                        (e) => e('name').asStringOrThrow().split('.').last,
                      ),
                    ),
                  ),
                );
              } on PickException catch (e) {
                throw AppUpdaterException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: e,
                );
              }
            }),
      )
      .future;

  /// Returns the latest release URL.
  String latestReleaseUrl() =>
      'https://github.com/${about.github!}/releases/latest';

  /// Returns donors bundled statically with the app.
  ///
  /// These can be used as a fallback in case the GitHub API is not available.
  Future<List<Donor>> bundledDonors() async {
    String raw = await rootBundle.loadString('assets/static/donations.json');
    return (json.decode(raw) as List<dynamic>)
        .map((e) => Donor.fromJson(e))
        .toList();
  }

  /// Returns donors from the GitHub repository.
  Future<List<Donor>> donors({bool force = false}) => donorCache
      .stream(
        QueryKey(const ['donors']),
        fetch: () => dio
            .get(
              'https://raw.githubusercontent.com/${about.github}/master/assets/static/donations.json',
            )
            .then((e) => jsonDecode(e.data))
            .then(
              (e) =>
                  (e as List<dynamic>).map((e) => Donor.fromJson(e)).toList(),
            ),
      )
      .future;
}

typedef AppUpdaterException = DioException;
