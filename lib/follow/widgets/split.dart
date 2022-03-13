import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsSplitPage extends StatefulWidget {
  @override
  _FollowsSplitPageState createState() => _FollowsSplitPageState();
}

class _FollowsSplitPageState extends State<FollowsSplitPage>
    with ListenerCallbackMixin {
  RefreshController refreshController = RefreshController();
  final FollowController controller = followController;

  @override
  Map<ChangeNotifier, VoidCallback> get listeners => {
        controller: updateRefresh,
      };

  Future<void> updateRefresh() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (controller.updating && mounted) {
        if (refreshController.headerMode?.value == RefreshStatus.idle) {
          await refreshController.requestRefresh(
            needCallback: false,
            duration: Duration(milliseconds: 100),
          );
          await controller.finish;
          if (mounted) {
            ScrollController? scrollController =
                PrimaryScrollController.of(context);
            if (scrollController?.hasClients ?? false) {
              scrollController?.animateTo(
                0,
                duration: defaultAnimationDuration,
                curve: Curves.easeInOut,
              );
            }
            if (controller.error == null) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, controller.update);
  }

  @override
  Widget build(BuildContext context) {
    return TileLayout(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => RefreshablePageLoader(
          onEmpty: Text('No follows'),
          onLoading: Text('Loading follows'),
          onError: Text('Failed to load follows'),
          isError: false,
          isLoading: false,
          isEmpty: controller.items.isEmpty,
          refreshController: refreshController,
          refreshHeader: RefreshablePageDefaultHeader(
            refreshingText:
                'Refreshing ${controller.progress} / ${controller.items.length}...',
          ),
          builder: (context) => StaggeredGridView.countBuilder(
            key: joinKeys(['follows', TileLayout.of(context).crossAxisCount]),
            padding: defaultListPadding,
            physics: BouncingScrollPhysics(),
            addAutomaticKeepAlives: false,
            crossAxisCount: TileLayout.of(context).crossAxisCount,
            itemCount: controller.items.length,
            itemBuilder: (context, index) =>
                FollowTile(follow: controller.items[index]),
            staggeredTileBuilder: (index) => StaggeredTile.count(
                1, 1 * TileLayout.of(context).tileHeightFactor),
          ),
          appBar: DefaultAppBar(
            title: Text('Following'),
            actions: [ContextDrawerButton()],
          ),
          refresh: () async {
            if (await validateCall(() => controller.update(force: true))) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          },
          drawer: NavigationDrawer(),
          endDrawer: ContextDrawer(
            title: Text('Follows'),
            children: [
              FollowSplitSwitchTile(),
              FollowMarkReadTile(),
              Divider(),
              FollowSettingsTile(),
            ],
          ),
        ),
      ),
    );
  }
}
