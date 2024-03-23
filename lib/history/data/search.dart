import 'package:e1547/history/history.dart';
import 'package:flutter/material.dart';

extension HistorySearchFilterDisplaying on HistoryCategory {
  String get title {
    switch (this) {
      case HistoryCategory.items:
        return 'Items';
      case HistoryCategory.searches:
        return 'Searches';
    }
  }

  Widget? get icon {
    switch (this) {
      case HistoryCategory.items:
        return const Icon(Icons.article);
      case HistoryCategory.searches:
        return const Icon(Icons.search);
    }
  }
}

extension HistoryTypeFilterDisplaying on HistoryType {
  String get title => switch (this) {
        HistoryType.posts => 'Posts',
        HistoryType.pools => 'Pools',
        HistoryType.topics => 'Topics',
        HistoryType.wikis => 'Wikis',
        HistoryType.users => 'Users'
      };

  Widget? get icon => switch (this) {
        HistoryType.posts => const Icon(Icons.image),
        HistoryType.pools => const Icon(Icons.collections),
        HistoryType.topics => const Icon(Icons.forum),
        HistoryType.users => const Icon(Icons.person),
        HistoryType.wikis => const Icon(Icons.info_outlined)
      };

  // region
  // TODO: these are all e6 specific
  // We need to come up with a generic solution

  String? get regex => switch (this) {
        HistoryType.posts => r'/posts/\d+',
        HistoryType.pools => r'/pools/\d+',
        HistoryType.topics => r'/forum_topics/\d+',
        HistoryType.wikis => r'/wiki_pages/\S+',
        HistoryType.users => r'/users/\S+'
      };

  String? get searchRegex => switch (this) {
        HistoryType.posts => r'/posts(\?.*)?',
        HistoryType.pools => r'/pools(\?.*)?',
        HistoryType.topics => r'/forum_topics(\?.*)?',
        HistoryType.wikis => r'/wiki_pages(\?.*)?',
        HistoryType.users => null
      };

  // endregion
}
