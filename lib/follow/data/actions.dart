import 'package:e1547/follow/follow.dart';

extension Utility on List<Follow> {
  List<String> get tags => map((e) => e.tags).toList();

  void sortByNew(String host) {
    sort(
      (a, b) {
        int result = 0;

        int unseenA = a.statuses[host]?.unseen ?? -1;
        int unseenB = b.statuses[host]?.unseen ?? -1;

        result = unseenB.compareTo(unseenA);

        if (result == 0) {
          int latestA = a.statuses[host]?.latest ?? -1;
          int latestB = b.statuses[host]?.latest ?? -1;

          result = latestB.compareTo(latestA);
        }

        if (result == 0) {
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        return result;
      },
    );
  }
}

Duration getFollowRefreshRate(int items) =>
    Duration(hours: (items * 0.04).clamp(0.5, 4).toInt());
