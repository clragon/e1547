import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/drift.dart';
import 'package:e1547/identity/identity.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class IdentitiesService extends IdentitiesDao with ChangeNotifier {
  IdentitiesService({
    required GeneratedDatabase database,
    this.onCreate,
  }) : super(database);

  StreamSubscription<Identity?>? _subscription;

  final FutureOr<IdentityRequest> Function()? onCreate;

  bool _disposed = false;

  Future<void> activate(int? id) async {
    final logger = Logger('IdentitiesService');
    _subscription?.cancel();
    Identity? result;
    Stream<Identity?>? stream;
    if (id != null) {
      stream = _find(id);
      result = await stream.firstOrNull;
      logger.info('activate: found identity $result');
    }
    if (result == null) {
      if (_disposed) return;
      result = (await page(page: 1, limit: 1)).singleOrNull;
      stream = _find(result?.id);
      logger.info('activate: defaulting identity $result');
    }
    if (result == null) {
      if (onCreate == null) {
        throw StateError(
          'IdentitiesService failed to activate because no identity '
          'was found and no onCreate callback was provided',
        );
      }
      if (_disposed) return;
      result = await add(await onCreate!());
      stream = _find(result.id);
      logger.info('activate: created identity $result');
    }
    _identity = result;
    _subscription = stream!.listen(_onChanged);
    if (_disposed) return;
    notifyListeners();
    logger.info('activate: activated identity $_identity');
  }

  Stream<Identity?> _find(int? id) => id == null
      ? Stream.value(null)
      : (select(identitiesTable)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  Future<void> _onChanged(Identity? value) async {
    if (value == null) return activate(null);
    if (value == _identity) return;
    _identity = value;
    notifyListeners();
  }

  Identity? _identity;

  Identity get identity {
    if (_identity == null) {
      throw StateError(
        'IdentityService was not activated before accessing '
        'the identity property',
      );
    }
    return _identity!;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
