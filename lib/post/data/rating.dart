import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

extension PostRatingInfo on Rating {
  Widget get icon {
    switch (this) {
      case Rating.s:
        return const Icon(Icons.check);
      case Rating.q:
        return const Icon(Icons.help);
      case Rating.e:
        return const Icon(Icons.warning);
    }
  }

  String get title {
    switch (this) {
      case Rating.s:
        return 'Safe';
      case Rating.q:
        return 'Questionable';
      case Rating.e:
        return 'Explicit';
    }
  }
}
