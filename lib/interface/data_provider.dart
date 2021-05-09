import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DataProvider<T> extends ChangeNotifier {
  bool reload = false;
  bool isLoading = false;
  bool isError = false;
  ValueNotifier<String> search = ValueNotifier('');
  ValueNotifier<List<List<T>>> pages = ValueNotifier([]);

  List<T> get items {
    return pages.value.expand((element) => element).toList();
  }

  @mustCallSuper
  DataProvider({String search}) {
    this.search.value = search ?? '';
    [db.host, db.credentials, this.search]
        .forEach((notifier) => notifier.addListener(resetPages));
    loadNextPage();
  }

  @mustCallSuper
  Future<void> resetPages() async {
    pages.value = [];
    if (isLoading) {
      reload = true;
    } else {
      loadNextPage(reset: true);
    }
  }

  Future<List<T>> provide(int page);

  Future<List<T>> transform(List<T> next) async => next;

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
      next = await transform(next);
      pages.value =
          reset ? [next] : pages.value = List.from(pages.value..add(next));
    }
  }

  @nonVirtual
  Future<void> loadNextPage({bool reset = false}) async {
    if (!isLoading) {
      isLoading = true;
      notifyListeners();
      int page = reset ? 1 : pages.value.length + 1;

      await addPage(await loadPage(page));

      isLoading = false;
      notifyListeners();
      if (reload) {
        reload = false;
        resetPages();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    search.dispose();
    pages.dispose();
  }
}
