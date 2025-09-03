import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:rxdart/rxdart.dart';

class HistoryRepo with Disposable {
  HistoryRepo({
    required this.persona,
    required this.client,
    required this.cache,
    required this.preferences,
    required this.identity,
    required this.traits,
  });

  final Persona persona;
  final HistoryClient client;
  final CachedQuery cache;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  // TODO: this is jank
  final SharedPreferences preferences;

  final String queryKey = 'histories';

  late final _historyCache = cache.bridge<History, int>(
    queryKey,
    fetch: (id) => get(id: id),
  );

  Future<History> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => client.get(id);

  Query<History> useGet({required int id, bool? vendored}) => Query(
    cache: cache,
    key: [queryKey, id],
    queryFn: () => get(id: id),
    config: _historyCache.getConfig(vendored: vendored),
  );

  Future<List<History>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final search = HistoryParams(value: query);
    return client.page(
      identity: identity.id,
      page: page,
      limit: limit,
      day: search.date,
      link: search.link?.infixRegex,
      category: search.categories,
      type: search.types,
      title: search.title?.infixRegex,
      subtitle: search.subtitle?.infixRegex,
    );
  }

  InfiniteQuery<List<int>, int> usePage({required QueryMap? query}) =>
      InfiniteQuery<List<int>, int>(
        cache: cache,
        key: [queryKey, query],
        getNextArg: (state) => state.nextPage,
        queryFn: (key) =>
            page(page: key, query: query).then(_historyCache.savePage),
      );

  Future<void> add(HistoryRequest request) async {
    if (!enabled) return;
    return client.transaction(() async {
      if (await client.isDuplicate(request)) return;
      if (trimming) {
        await client.trim(
          maxAmount: trimAmount,
          maxAge: trimAge,
          identity: identity.id,
        );
      }
      if (!enabled) return;
      return client.add(request, identity.id);
    });
  }

  Mutation<void, HistoryRequest> useAdd() => Mutation(
    mutationFn: (request) => add(request),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Mutation<void, List<int>> useRemove() => Mutation(
    mutationFn: (ids) => removeAll(ids),
    onSuccess: (_, __) => cache.invalidateCache(
      filterFn: (key, _) => key is List && key.first == queryKey,
    ),
  );

  Future<void> removeAll(List<int>? ids) =>
      client.removeAll(ids, identity: identity.id);

  Future<int> count() => client.length(identity: identity.id);

  Query<int> useCount() =>
      Query(cache: cache, key: [queryKey, 'count'], queryFn: () => count());

  Future<List<DateTime>> days() => client.days(identity: identity.id);

  Query<List<DateTime>> useDays() =>
      Query(cache: cache, key: [queryKey, 'days'], queryFn: () => days());

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
