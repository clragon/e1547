import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowsCombinedPage extends StatefulWidget {
  @override
  State<FollowsCombinedPage> createState() => _FollowsCombinedPageState();
}

class _FollowsCombinedPageState extends State<FollowsCombinedPage>
    with ListenerCallbackMixin {
  List<String?>? tags;

  PostController controller = PostController(
    provider: (tags, page, force) => client.follows(page, force: force),
    canSearch: false,
  );

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        followController: updateTags,
      };

  Future<void> updateTags() async {
    List<String?> update = followController.items.tags;
    if (tags == null) {
      tags = update;
    } else if (!listEquals(tags, update)) {
      controller.refresh();
      tags = update;
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      controller: controller,
      appBar: const DefaultAppBar(
        title: Text('Following'),
        actions: [
          ContextDrawerButton(),
        ],
      ),
      drawerActions: const [
        FollowSplitSwitchTile(),
        FollowSettingsTile(),
      ],
    );
  }
}
