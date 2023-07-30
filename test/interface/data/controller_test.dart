import 'dart:async';

import 'package:e1547/interface/data/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void verifyFirstRequest(DataController controller) {
    expect(controller.items, orderedEquals(const [MockItem('1')]));
    expect(controller.nextPageKey, 2);
    expect(controller.error, null);
  }

  Future<PageResponse<int, MockItem>> mockSecondRequest(
    int page,
    bool force,
  ) async {
    return const PageResponse(
      items: [MockItem('end')],
      nextPageKey: 7,
    );
  }

  void verifySecondRequest(DataController controller) {
    expect(controller.items, orderedEquals(const [MockItem('end')]));
    expect(controller.nextPageKey, 7);
    expect(controller.error, null);
  }

  group('DataController', () {
    test('should request a page', () async {
      final controller = MockDataController();
      expect(controller.items, null);
      expect(controller.nextPageKey, 1);
      expect(controller.error, null);
      await controller.getNextPage();
      verifyFirstRequest(controller);
    });

    test('should set error on failure', () async {
      final controller = MockDataController();
      final error = Object();
      controller.mockPerformRequest = (page, force) async {
        return PageResponse.error(error: error);
      };
      await controller.getNextPage();
      expect(controller.items, null);
      expect(controller.nextPageKey, 1);
      expect(controller.error, error);
    });

    test('should not request another page if last page', () async {
      final controller = MockDataController();
      controller.mockPerformRequest = (page, force) async {
        return const PageResponse.last(
          items: [MockItem('1')],
        );
      };
      await controller.getNextPage();
      expect(controller.items!.length, 1);
      expect(controller.nextPageKey, null);
      expect(controller.error, null);
      bool success = true;
      controller.mockPerformRequest = (page, force) async {
        success = false;
        return const PageResponse.error(error: Object());
      };
      await controller.getNextPage();
      expect(success, true);
      expect(controller.items!.length, 1);
      expect(controller.nextPageKey, null);
      expect(controller.error, null);
    });

    test('should not request two pages at once', () async {
      final controller = MockDataController();
      final done1 = controller.getNextPage();
      final done2 = controller.getNextPage();
      await [done1, done2].wait;
      expect(controller.items, orderedEquals(const [MockItem('1')]));
      expect(controller.nextPageKey, 2);
      expect(controller.error, null);
    });

    test('should reset pages on refresh', () async {
      bool success = false;
      final controller = MockDataController();
      await controller.getNextPage();
      verifyFirstRequest(controller);
      controller.mockPerformRequest = (page, force) async {
        success = force;
        return mockSecondRequest(page, force);
      };
      await controller.refresh();
      verifySecondRequest(controller);
      expect(success, true);
    });

    test('should reset error on refresh', () async {
      final controller = MockDataController();
      controller.mockPerformRequest = (page, force) async {
        return const PageResponse.error(error: Object());
      };
      await controller.getNextPage();
      expect(controller.error, isNotNull);
      controller.mockPerformRequest = null;
      await controller.refresh();
      expect(controller.error, null);
    });

    test('should background refresh', () async {
      final controller = MockDataController();
      await controller.getNextPage();
      verifyFirstRequest(controller);
      final completer1 = Completer<void>();
      final completer2 = Completer<void>();
      controller.mockPerformRequest = (page, force) async {
        completer1.complete();
        await completer2.future;
        return mockSecondRequest(page, force);
      };
      controller.refresh(background: true);
      await completer1.future;
      expect(controller.items!, orderedEquals(const [MockItem('1')]));
      expect(controller.nextPageKey, 2);
      expect(controller.error, null);
      completer2.complete();
      await Future.value();
      verifySecondRequest(controller);
    });

    test('should schedule a reset', () async {
      final controller = MockDataController();
      final completer = Completer<void>();
      controller.mockPerformRequest = (page, force) async {
        await completer.future;
        return MockDataController.defaultMockPerformRequest(page, force);
      };
      controller.getNextPage();
      controller.mockPerformRequest = mockSecondRequest;
      final done = controller.refresh();
      completer.complete();
      await done;
      verifySecondRequest(controller);
    });

    test('should only run the last scheduled reset', () async {
      final controller = MockDataController();
      final completer1 = Completer<void>();
      final completer2 = Completer<void>();
      controller.mockPerformRequest = (page, force) async {
        await completer1.future;
        return MockDataController.defaultMockPerformRequest(page, force);
      };
      controller.getNextPage();
      controller.mockPerformRequest = (page, force) async {
        await completer2.future;
        return mockSecondRequest(page, force);
      };
      controller.refresh();
      controller.refresh(background: true);
      await Future.value();
      completer1.complete();
      await Future.value();
      verifyFirstRequest(controller);
      completer2.complete();
      await Future.value();
      verifySecondRequest(controller);
    });

    test('can be disposed', () async {
      final controller = MockDataController();
      expect(() => controller.dispose(), returnsNormally);
    });
  });

  group('DataControllerItemManipulation Extension', () {
    test('can update an item', () async {
      final controller = MockDataController();
      await controller.getNextPage();
      verifyFirstRequest(controller);
      controller.updateItem(0, const MockItem('2'));
      expect(controller.items, orderedEquals(const [MockItem('2')]));
    });

    test('throws an error if index is -1', () async {
      final controller = MockDataController();
      await controller.getNextPage();
      expect(() => controller.updateItem(-1, const MockItem('2')),
          throwsStateError);
    });

    test('throws an error if items is null', () async {
      final controller = MockDataController();
      expect(() => controller.updateItem(0, const MockItem('2')),
          throwsStateError);
    });

    test('can assert item ownership', () async {
      final controller = MockDataController();
      expect(() => controller.assertOwnsItem(const MockItem('never')),
          throwsStateError);
      await controller.getNextPage();
      expect(() => controller.assertOwnsItem(const MockItem('1')),
          returnsNormally);
      expect(() => controller.assertOwnsItem(const MockItem('never')),
          throwsStateError);
    });
  });

  group('PageLoading Extension', () {
    test('can wait for the first page', () async {
      final controller = MockDataController();
      await controller.waitForFirstPage();
      expect(controller.items, orderedEquals(const [MockItem('1')]));
      expect(controller.nextPageKey, 2);
      expect(controller.error, null);
    });
  });
}

@immutable
class MockItem {
  const MockItem(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MockItem && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MockItem($id)';
}

class MockDataController extends DataController<int, MockItem> {
  MockDataController({super.firstPageKey = 1});

  Future<PageResponse<int, MockItem>> Function(int page, bool force)?
      mockPerformRequest;

  static Future<PageResponse<int, MockItem>> defaultMockPerformRequest(
      int page, bool force) async {
    return PageResponse(
      items: [MockItem(page.toString())],
      nextPageKey: page + 1,
    );
  }

  @override
  Future<PageResponse<int, MockItem>> performRequest(
      int page, bool force) async {
    if (mockPerformRequest != null) {
      return mockPerformRequest!(page, force);
    } else {
      return defaultMockPerformRequest(page, force);
    }
  }
}
