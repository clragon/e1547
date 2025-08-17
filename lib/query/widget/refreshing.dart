import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SubValue(
      create: () => RefreshController(),
      builder: (context, refreshController) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f5): () => refreshController
              .requestRefresh(duration: const Duration(milliseconds: 100)),
        },
        child: FocusScope(
          autofocus: true,
          child: SmartRefresher(
            controller: refreshController,
            onRefresh: () async {
              try {
                await onRefresh();
                refreshController.refreshCompleted();
              } on Object {
                refreshController.refreshFailed();
              }
            },
            header: const ClassicHeader(),
            child: child,
          ),
        ),
      ),
    );
  }
}
