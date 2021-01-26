import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class DataProvider<T> {
  bool willLoad = false;
  bool isLoading = false;
  ValueNotifier<String> search = ValueNotifier('');
  ValueNotifier<List<List<T>>> pages = ValueNotifier([]);
  Future<List<T>> Function(String search, int page) provider;
  Future<List<T>> Function(String search, List<List<T>> pages) extendedProvider;

  List<T> get items {
    return pages.value
        .fold<Iterable<T>>(Iterable.empty(), (a, b) => a.followedBy(b))
        .toList();
  }

  void _init(String search) {
    this.search.value = search ?? '';
    // this should probably include db.denylist,
    // but it will break wiki dialogues
    [db.host, db.credentials, this.search]
        .forEach((notifier) => notifier.addListener(resetPages));
    loadNextPage();
  }

  DataProvider({String search, @required this.provider}) {
    _init(search);
  }

  DataProvider.extended({String search, @required this.extendedProvider}) {
    _init(search);
  }

  Future<void> resetPages() async {
    pages.value = [];
    if (pages.value.length == 0) {
      if (isLoading) {
        willLoad = true;
      } else {
        loadNextPage(reset: true);
      }
    }
  }

  Future<void> loadNextPage({bool reset = false}) async {
    if (!isLoading) {
      isLoading = true;
      List<T> nextPage = [];

      int page = reset ? 1 : pages.value.length + 1;

      if (extendedProvider != null) {
        nextPage.addAll(await extendedProvider(search.value, pages.value));
      } else {
        nextPage.addAll(await provider(search.value, page));
      }

      if (nextPage.length != 0 || pages.value.length == 0) {
        if (reset) {
          pages.value = [nextPage];
        } else {
          pages.value = List.from(pages.value..add(nextPage));
        }
      }
      isLoading = false;
      if (willLoad) {
        willLoad = false;
        resetPages();
      }
    }
  }
}
