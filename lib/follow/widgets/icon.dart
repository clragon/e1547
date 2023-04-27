import 'package:e1547/follow/follow.dart';
import 'package:flutter/material.dart';

IconData getFollowIcon(FollowType type) {
  switch (type) {
    case FollowType.update:
      return Icons.update;
    case FollowType.notify:
      return Icons.notifications_active;
    case FollowType.bookmark:
      return Icons.bookmark;
  }
}
