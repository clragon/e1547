import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/mock_item.dart';

void main() {
  group('ClientDataController', () {
    test('cancels on dispose', () async {
      final controller = MockPageClientDataController();
      controller.getNextPage();
      expect(controller.dispose, returnsNormally);
      expect(controller.cancelToken.isCancelled, isTrue);
      expect(controller.items, null);
    });
  });

  group('PageClientDataController', () {
    test('fetches pages', () async {
      final controller = MockPageClientDataController();
      await controller.getNextPage();
      expect(controller.items, const [MockItem(1)]);
      expect(controller.nextPageKey, 2);
      expect(controller.error, isNull);
      await controller.getNextPage();
      expect(controller.items, const [MockItem(1), MockItem(2)]);
      expect(controller.nextPageKey, 3);
      expect(controller.error, isNull);
    });

    test('treats empty pages as the last page', () async {
      final controller = MockPageClientDataController();
      await controller.getNextPage();
      expect(controller.items, const [MockItem(1)]);
      controller.mockFetch = (page, force) async => [];
      await controller.getNextPage();
      expect(controller.items, const [MockItem(1)]);
    });

    test('sets error when fetch fails', () async {
      final controller = MockPageClientDataController();
      controller.mockFetch = (page, force) async {
        throw FakeClientException();
      };
      await controller.getNextPage();
      expect(controller.items, null);
      expect(controller.error, isA<FakeClientException>());
    });

    test('cancels previous request when resetting', () async {
      final controller = MockPageClientDataController();
      final cancelToken = controller.cancelToken;
      final completer = Completer<void>();
      controller.mockFetch = (page, force) async {
        await completer.future;
        return [const MockItem('end')];
      };
      controller.getNextPage();
      controller.mockFetch = (page, force) async {
        return [const MockItem('end')];
      };
      final done = controller.refresh();
      await Future.value();
      expect(cancelToken.isCancelled, isTrue);
      completer.complete();
      await done;
      expect(controller.items, const [MockItem('end')]);
    });

    test('can evict cache', () async {
      final controller = MockPageClientDataController();
      await controller.getNextPage();
      expect(controller.items, const [MockItem(1)]);
      bool success = false;
      controller.mockFetch = (page, force) async {
        if (force) {
          success = true;
        }
        return [const MockItem('end')];
      };
      controller.evictCache();
      await Future.value();
      controller.mockFetch = null;
      await controller.refresh();
      expect(success, isTrue);
      expect(controller.items, const [MockItem(1)]);
    });
  });
}

class FakeClientException extends Fake implements ClientException {}

class MockPageClientDataController extends PageClientDataController<MockItem> {
  MockPageClientDataController({super.firstPageKey = 1});

  @override
  Client get client => throw UnimplementedError();

  Future<List<MockItem>> Function(int page, bool force)? mockFetch;

  static Future<List<MockItem>> Function(int page, bool force)
  defaultMockFetch = (page, force) async => [MockItem(page)];

  @override
  Future<void> evictCache() => super.evictCache();

  @override
  Future<List<MockItem>> fetch(int page, bool force) async {
    final completer = Completer<List<MockItem>>();
    cancelToken.whenCancel.then((_) {
      if (completer.isCompleted) return;
      completer.completeError(FakeClientException());
    });
    if (mockFetch != null) {
      completer.complete(mockFetch!(page, force));
    } else {
      completer.complete(defaultMockFetch(page, force));
    }
    return completer.future;
  }
}
