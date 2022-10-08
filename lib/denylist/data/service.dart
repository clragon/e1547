import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class DenylistService extends DataUpdater with DataLock<List<String>> {
  DenylistService({
    required Client client,
    required ValueNotifier<List<String>> source,
  })  : _client = client,
        _source = source {
    _source.addListener(notifyListeners);
  }

  final Client _client;
  final ValueNotifier<List<String>> _source;

  List<String> get items => _source.value;

  @override
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..addAll([_client]);

  @override
  @protected
  Future<List<String>> read() async => List.from(items);

  @override
  @protected
  Future<void> write(List<String> value, {bool upload = true}) async {
    _source.value = value;
    if (upload && _client.hasLogin) {
      await _client.updateBlacklist(items);
    }
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  @protected
  Future<void> protect(
    DataUpdate<List<String>> updater, {
    bool upload = true,
  }) async {
    await resourceLock.acquire();
    List<String> updated = await updater(await read());
    await write(updated, upload: upload);
    resourceLock.release();
  }

  @override
  @protected
  Future<void> run(bool force) async {
    CurrentUser? user = await _client.currentUser(force: force);
    if (user != null) {
      try {
        await protect(
          (data) => user.blacklistedTags.split('\n').trim(),
          upload: false,
        );
      } on DioError {
        throw UpdaterException(message: 'Could not update blacklist');
      }
    }
  }

  bool denies(String value) => items.contains(value);

  Future<void> add(String value) async => protect((data) => data..add(value));

  Future<void> remove(String value) async =>
      protect((data) => data..remove(value));

  Future<void> removeAt(int index) async =>
      protect((data) => data..removeAt(index));

  Future<void> replace(String oldValue, String value) async =>
      protect((data) => data..[items.indexOf(oldValue)] = value);

  Future<void> replaceAt(int index, String value) async =>
      protect((data) => data..[index] = value);

  Future<void> edit(List<String> value) async => protect((data) => value);
}

class DenylistProvider
    extends SubChangeNotifierProvider2<Settings, Client, DenylistService> {
  DenylistProvider()
      : super(
          create: (context, settings, client) => DenylistService(
            client: client,
            source: settings.denylist,
          ),
        );
}
