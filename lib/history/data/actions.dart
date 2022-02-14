import 'package:e1547/client/data/client.dart';
import 'package:e1547/history/data/entry.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';

void addPostToHistory(Post post) {
  if (!settings.writeHistory.value) {
    return;
  }
  withHistory((history) {
    if (history.reversed.take(15).any((element) =>
        element.postId == post.id &&
        element.visitedAt.difference(DateTime.now()).inMinutes < 10)) {
      return;
    }
    String? thumbnail;
    if (!post.isDeniedBy(settings.denylist.value)) {
      thumbnail = post.sample.url;
    }
    history.add(
      HistoryEntry(
          visitedAt: DateTime.now(), postId: post.id, thumbnail: thumbnail),
    );
  });
}

void addToHistory(HistoryEntry historyEntry) {
  withHistory((history) => history.add(historyEntry));
}

void removeFromHistory(HistoryEntry historyEntry) {
  withHistory((history) => history.remove(historyEntry));
}

void withHistory(void Function(List<HistoryEntry> history) callback) {
  String host = client.host;
  Map<String, List<HistoryEntry>> history = Map.from(settings.history.value);
  List<HistoryEntry> currentHistory = history[host] ?? [];
  callback(currentHistory);
  currentHistory.sort((a, b) => a.visitedAt.compareTo(b.visitedAt));
  history[host] = currentHistory;
  settings.history.value = history;
}
