import 'dart:async';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/cupertino.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:rxdart/rxdart.dart';

class DiskHistoryService extends HistoryService with Disposable {
  DiskHistoryService({
    required this.database,
    required this.preferences,
    required this.identity,
    required this.traits,
  }) : repository = HistoryRepository(database: database);

  final GeneratedDatabase database;
  final Identity identity;
  @override
  final ValueNotifier<Traits> traits;
  // TODO: this is jank
  final SharedPreferences preferences;
  final HistoryRepository repository;

  @override
  Future<History> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      repository.get(id);

  @override
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

  @override
  Future<void> add(HistoryRequest request) =>
      repository.add(request, identity.id);

  @override
  Future<void> addMaybe(HistoryRequest request) async {
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
      return super.addMaybe(request);
    });
  }

  @override
  Future<void> removeAll(List<int>? ids) =>
      repository.removeAll(ids, identity: identity.id);

  @override
  Future<int> count() => repository.length(identity: identity.id);

  @override
  Future<List<DateTime>> days() => repository.days(identity: identity.id);

  @override
  bool get enabled => _enabled;
  @override
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _enabledStream.add(value);
    preferences.setBool('writeHistory', value);
  }

  // TODO: this should be a trait, not a setting
  late bool _enabled = preferences.getBool('writeHistory') ?? true;

  @override
  Stream<bool> get enabledStream => _enabledStream.stream;
  final StreamController<bool> _enabledStream = BehaviorSubject<bool>();

  // TODO: this should be a trait, not a setting
  late bool _trimming = preferences.getBool('trimHistory') ?? false;

  @override
  bool get trimming => _trimming;
  @override
  set trimming(bool value) {
    if (_trimming == value) return;
    _trimming = value;
    _trimmingStream.add(value);
    preferences.setBool('trimHistory', value);
  }

  @override
  Stream<bool> get trimmingStream => _trimmingStream.stream;
  final StreamController<bool> _trimmingStream = BehaviorSubject<bool>();

  @override
  int get trimAmount => 5000;

  @override
  Duration get trimAge => const Duration(days: 30 * 3);

  @override
  void dispose() {
    _enabledStream.close();
    _trimmingStream.close();
    super.dispose();
  }
}
