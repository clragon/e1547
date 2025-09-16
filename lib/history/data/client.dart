import 'dart:async';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:rxdart/rxdart.dart';

class HistoryClient with Disposable {
  HistoryClient({
    required this.database,
    required this.preferences,
    required this.identity,
    required this.traits,
  }) : repository = HistoryRepository(database: database);

  final GeneratedDatabase database;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  // TODO: this is jank
  final SharedPreferences preferences;
  final HistoryRepository repository;

  Future<History> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => repository.get(id);

  Future<List<History>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final search = HistoryQuery.maybeFrom(query);
    return repository.page(
      identity: identity.id,
      page: page,
      limit: limit,
      day: search?.date,
      link: search?.link?.infixRegex,
      category: search?.categories,
      type: search?.types,
      title: search?.title?.infixRegex,
      subtitle: search?.subtitle?.infixRegex,
    );
  }

  Future<void> add(HistoryRequest request) async {
    if (!enabled) return;
    return repository.transaction(() async {
      if (await repository.isDuplicate(request)) return;
      if (trimming) {
        await repository.trim(
          maxAmount: trimAmount,
          maxAge: trimAge,
          identity: identity.id,
        );
      }
      return repository.add(request, identity.id);
    });
  }

  Future<void> remove(int id) => removeAll([id]);

  Future<void> removeAll(List<int>? ids) =>
      repository.removeAll(ids, identity: identity.id);

  Future<int> count() => repository.length(identity: identity.id);

  Future<List<DateTime>> days() => repository.days(identity: identity.id);

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _enabledStream.add(value);
    preferences.setBool('writeHistory', value);
  }

  // TODO: this should be a trait, not a setting
  late bool _enabled = preferences.getBool('writeHistory') ?? true;

  Stream<bool> get enabledStream => _enabledStream.stream;
  final StreamController<bool> _enabledStream = BehaviorSubject<bool>();

  // TODO: this should be a trait, not a setting
  late bool _trimming = preferences.getBool('trimHistory') ?? false;

  bool get trimming => _trimming;
  set trimming(bool value) {
    if (_trimming == value) return;
    _trimming = value;
    _trimmingStream.add(value);
    preferences.setBool('trimHistory', value);
  }

  Stream<bool> get trimmingStream => _trimmingStream.stream;
  final StreamController<bool> _trimmingStream = BehaviorSubject<bool>();

  int get trimAmount => 5000;

  Duration get trimAge => const Duration(days: 30 * 3);

  @override
  void dispose() {
    _enabledStream.close();
    _trimmingStream.close();
    super.dispose();
  }
}
