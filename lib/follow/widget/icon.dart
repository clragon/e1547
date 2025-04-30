import 'package:e1547/follow/follow.dart';
import 'package:flutter/material.dart';

extension FollowIcon on FollowType {
  Widget get icon {
    switch (this) {
      case FollowType.notify:
        return const Icon(Icons.notifications_active);
      case FollowType.update:
        return const Icon(Icons.person_add);
      case FollowType.bookmark:
        return const Icon(Icons.bookmark);
    }
  }
}
