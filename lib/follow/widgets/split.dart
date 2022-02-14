import 'package:e1547/client/client.dart';
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

  Future<void> refreshFollows({bool force = false}) async {
    await controller.update(force: force);
    if (mounted) {
      setState(() {});
    }
  }

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
            if (!controller.error) {
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
    Future.delayed(Duration(milliseconds: 500), refreshFollows);
  }

  @override
  Widget build(BuildContext context) {
    return TileLayoutScope(
      tileBuilder: (tileHeightFactor, crossAxisCount, stagger) =>
          (index) => StaggeredTile.count(1, 1 * tileHeightFactor),
      builder: (context, crossAxisCount, tileBuilder) => AnimatedBuilder(
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
            key: joinKeys(['follows', tileBuilder, crossAxisCount]),
            padding: defaultListPadding,
            physics: BouncingScrollPhysics(),
            addAutomaticKeepAlives: false,
            crossAxisCount: crossAxisCount,
            itemCount: controller.items.length,
            itemBuilder: (context, index) => FollowTile(
              follow: controller.items[index],
              host: client.host,
            ),
            staggeredTileBuilder: tileBuilder,
          ),
          appBar: DefaultAppBar(
            title: Text('Following'),
            actions: [
              ContextDrawerButton(),
            ],
          ),
          refresh: () async {
            if (await validateCall(() => refreshFollows(force: true))) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          },
          drawer: defaultNavigationDrawer(),
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
