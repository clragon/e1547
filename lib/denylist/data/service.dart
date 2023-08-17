import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

class DenylistService extends ChangeNotifier {
  DenylistService({
    List<String>? items,
    DenylistPull? pull,
    DenylistPush? push,
  })  : _items = items ?? [],
        _pull = pull,
        _push = push;

  List<String> _items;

  List<String> get items => _items;

  final Mutex _resourceLock = Mutex();

  bool _disposed = false;

  @protected
  Future<void> protect(
          FutureOr<List<String>> Function(List<String> data) updater) async =>
      _resourceLock.protect(
        () async {
          _items = await updater(List.from(items));
          if (_disposed) return;
          if (listEquals(items, _items)) return;
          notifyListeners();
          await push();
        },
      );

  final DenylistPull? _pull;
  final DenylistPush? _push;

  /// Updates the denied list from a remote, if available.
  Future<void> pull() async {
    if (_pull == null) return;
    List<String>? updated = await _pull!();
    if (updated == null) return;
    set(updated);
  }

  /// Updates a remote with the denied list, if available.
  Future<void> push() async {
    if (_push == null) return;
    await _push!(items);
  }

  /// Returns true if [value] is in the list.
  bool denies(String value) => items.contains(value);

  /// Adds an entry to the denied list.
  Future<void> add(String value) async => protect((data) => data..add(value));

  /// Removes an entry of the denied list by value.
  Future<void> remove(String value) async =>
      protect((data) => data..remove(value));

  /// Removes an entry of the denied list at [index].
  Future<void> removeAt(int index) async =>
      protect((data) => data..removeAt(index));

  /// Replaces an entry of the denied list by its old value.
  Future<void> replace(String oldValue, String value) async =>
      protect((data) => data..[items.indexOf(oldValue)] = value);

  /// Replaces an entry of the denied list at [index].
  Future<void> replaceAt(int index, String value) async =>
      protect((data) => data..[index] = value);

  /// Replaces the entire denied entry list.
  Future<void> set(List<String> value) async => protect((data) => value.trim());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class DenylistUpdateException implements Exception {
  /// Thrown if a push or pull operation in [DenylistService] fails.
  DenylistUpdateException({this.message});

  /// The reason for failure.
  final String? message;
}

typedef DenylistPull = AsyncValueGetter<List<String>?>;
typedef DenylistPush = AsyncValueSetter<List<String>>;
