import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/data/current.dart';
import 'package:flutter/material.dart';

DenylistController denylistController = DenylistController();

class DenylistController extends DataUpdater<List<String>> {
  late final ValueNotifier<List<String>> _source;

  List<String> get items => List.from(_source.value);

  @override
  @protected
  Future<List<String>> read() async => (items);

  @override
  @protected
  Future<void> write(List<String> value, {bool upload = true}) async {
    _source.value = value;
    if (upload && client.hasLogin) {
      await client.updateBlacklist(items);
    }
  }

  DenylistController() {
    _source = settings.denylist;
    _source.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  @protected
  Future<void> withData(DataUpdate<List<String>> updater,
      {bool upload = true}) async {
    await resourceLock.acquire();
    List<String> updated = await updater(await read());
    await write(updated, upload: true);
    resourceLock.release();
  }

  @override
  @protected
  Future<void> run(bool force) async {
    CurrentUser? user = await client.currentUser(force: force);
    if (user != null) {
      try {
        withData((data) => user.blacklistedTags.split('\n').trim(),
            upload: false);
      } on DioError {
        throw UpdaterException(message: 'Could not update blacklist');
      }
    }
  }

  bool denies(String value) => items.contains(value);

  Future<void> add(String value) async => withData((data) => data..add(value));

  Future<void> remove(String value) async =>
      withData((data) => data..remove(value));

  Future<void> removeAt(int index) async =>
      withData((data) => data..removeAt(index));

  Future<void> replace(String oldValue, String value) async =>
      withData((data) => data..[items.indexOf(oldValue)] = value);

  Future<void> replaceAt(int index, String value) async =>
      withData((data) => data..[index] = value);

  Future<void> edit(List<String> value) async => withData((data) => value);
}
