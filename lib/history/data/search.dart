import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search.freezed.dart';

part 'search.g.dart';

@freezed
class HistoriesSearch with _$HistoriesSearch {
  const HistoriesSearch._();

  const factory HistoriesSearch({
    DateTime? date,
    required Set<HistorySearchFilter> searchFilters,
    required Set<HistoryTypeFilter> typeFilters,
  }) = _HistoriesSearch;

  factory HistoriesSearch.fromJson(dynamic json) =>
      _$HistoriesSearchFromJson(json);

  String buildLinkFilter() {
    String? regexShell(String? regex) =>
        regex != null ? r'^' '($regex)' r'$' : null;
    List<String?> regexes = [];
    for (final searchFilter in searchFilters) {
      switch (searchFilter) {
        case HistorySearchFilter.items:
          regexes.addAll((typeFilters.map((e) => regexShell(e.regex))));
          break;
        case HistorySearchFilter.searches:
          regexes.addAll((typeFilters.map((e) => regexShell(e.searchRegex))));
          break;
      }
    }
    regexes.removeWhere((e) => e == null);
    regexes.add(r'^$');
    return regexes.join('|');
  }
}

@JsonEnum()
enum HistorySearchFilter {
  items,
  searches;

  String get title {
    switch (this) {
      case HistorySearchFilter.items:
        return 'Items';
      case HistorySearchFilter.searches:
        return 'Searches';
    }
  }

  Widget? get icon {
    switch (this) {
      case HistorySearchFilter.items:
        return const Icon(Icons.article);
      case HistorySearchFilter.searches:
        return const Icon(Icons.search);
    }
  }
}

@JsonEnum()
enum HistoryTypeFilter {
  posts,
  pools,
  topics,
  users,
  wikis;

  String get title {
    switch (this) {
      case posts:
        return 'Posts';
      case pools:
        return 'Pools';
      case topics:
        return 'Topics';
      case wikis:
        return 'Wikis';
      case users:
        return 'Users';
    }
  }

  Widget? get icon {
    switch (this) {
      case HistoryTypeFilter.posts:
        return const Icon(Icons.image);
      case HistoryTypeFilter.pools:
        return const Icon(Icons.collections);
      case HistoryTypeFilter.topics:
        return const Icon(Icons.forum);
      case HistoryTypeFilter.users:
        return const Icon(Icons.person);
      case HistoryTypeFilter.wikis:
        return const Icon(Icons.info_outlined);
    }
  }

  String? get regex {
    switch (this) {
      case posts:
        return r'/posts/\d+';
      case pools:
        return r'/pools/\d+';
      case topics:
        return r'/forum_topics/\d+';
      case wikis:
        return r'/wiki_pages/[^\s]+';
      case users:
        return r'/users/[^\s]+';
    }
  }

  String? get searchRegex {
    switch (this) {
      case posts:
        return r'/posts(\?.*)?';
      case pools:
        return r'/pools(\?.*)?';
      case topics:
        return r'/forum_topics(\?.*)?';
      case wikis:
        return r'/wiki_pages(\?.*)?';
      case users:
        return null;
    }
  }
}
