import 'package:e1547/history/history.dart';

extension Identification on History {
  bool get isPost {
    return RegExp(r'^/posts/\d+$').hasMatch(link);
  }

  bool get isPool {
    return RegExp(r'^/pools/\d+$').hasMatch(link);
  }

  bool get isSearch {
    return RegExp(r'^/posts?tags=.*').hasMatch(link);
  }

  String get name {
    if (title != null) {
      return title!;
    }
    // TODO: implement extracting ID or tags
    return link;
  }
}
