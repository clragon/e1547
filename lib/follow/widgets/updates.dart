import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowUpdates extends StatefulWidget {
  const FollowUpdates({super.key, required this.builder});

  final Widget Function(BuildContext context, RefreshController controller)
      builder;

  @override
  State<FollowUpdates> createState() => _FollowUpdatesState();
}

class _FollowUpdatesState extends State<FollowUpdates> {
  final RefreshController refreshController = RefreshController();

  void onRemaining(int remaining) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          bool collapsed =
              refreshController.headerMode?.value == RefreshStatus.idle;
          if (remaining > 0) {
            if (collapsed) {
              refreshController.requestRefresh(
                needCallback: false,
                duration: const Duration(milliseconds: 100),
              );
            }
          } else {
            if (!collapsed) {
              refreshController.refreshCompleted();
              ScrollController scrollController =
                  PrimaryScrollController.of(context);
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  0,
                  duration: defaultAnimationDuration,
                  curve: Curves.easeInOut,
                );
              }
            }
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<FollowsUpdater>().update(
                client: context.read<Client>(),
              ),
        );
        return null;
      },
      keys: const [],
      child: SubEffect(
        effect: () => context
            .read<FollowsUpdater>()
            .remaining
            .listen(
              onRemaining,
              onError: (exception) => refreshController.refreshFailed(),
            )
            .cancel,
        keys: [context.watch<FollowsUpdater>().value],
        child: widget.builder(context, refreshController),
      ),
    );
  }
}
