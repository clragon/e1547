import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

abstract class DataProvider<T> extends ChangeNotifier {
  ValueNotifier<List<List<T>>> pages = ValueNotifier([]);
  ValueNotifier<String> search = ValueNotifier('');
  Mutex updateLock = Mutex();
  bool isRestarting = false;
  bool isLoading = false;
  bool isError = false;

  List<T> get items => pages.value.expand((element) => element).toList();

  @mustCallSuper
  DataProvider({String search}) {
    this.search.value = search ?? '';
    [db.host, db.credentials, this.search]
        .forEach((element) => element.addListener(resetPages));
    onInit();
  }

  @mustCallSuper
  Future<void> resetPages() async {
    pages.value = [];
    if (isLoading) {
      isRestarting = true;
    } else {
      loadNextPage(reset: true);
    }
  }

  Future<void> onInit() async => loadNextPage();

  Future<List<T>> provide(int page);

  Future<List<T>> transform(List<T> next, List<List<T>> current) async => next;

  Future<void> refresh() async {}

  Future<List<T>> catchError(Future<List<T>> Function() callback) async {
    isError = false;
    try {
      return await callback();
    } on DioError {
      isError = true;
      return [];
    }
  }

  @nonVirtual
  Future<List<T>> loadPage(int page) => catchError(() => provide(page));

  @nonVirtual
  Future<void> addPage(List<T> next, {bool reset = false}) async {
    if (next.isNotEmpty || pages.value.isEmpty) {
      List<List<T>> current = reset ? [] : pages.value = List.from(pages.value);
      next = await transform(next, List.from(current));
      pages.value = current..add(next);
      await refresh();
    }
  }

  @nonVirtual
  Future<void> loadNextPage({bool reset = false}) async {
    if (updateLock.isLocked) {
      return;
    }
    isLoading = true;
    await updateLock.acquire();
    notifyListeners();
    int page = reset ? 1 : pages.value.length + 1;

    await addPage(await loadPage(page), reset: reset);

    isLoading = false;
    notifyListeners();
    if (isRestarting) {
      isRestarting = false;
      resetPages();
    }
    updateLock.release();
  }

  @override
  void dispose() {
    super.dispose();
    [db.host, db.credentials, this.search]
        .forEach((element) => element.removeListener(resetPages));
    search.dispose();
    pages.dispose();
  }
}
