import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowsCombinedPage extends StatefulWidget {
  @override
  _FollowsCombinedPageState createState() => _FollowsCombinedPageState();
}

class _FollowsCombinedPageState extends State<FollowsCombinedPage>
    with LinkingMixin {
  List<String?>? tags;

  PostController provider = PostController(
    provider: (tags, page, force) => client.follows(page, force: force),
    canSearch: false,
  );

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.follows: updateTags,
      };

  Future<void> updateTags() async {
    List<String?> update = settings.follows.value.tags;
    if (tags == null) {
      tags = update;
    } else if (!listEquals(tags, update)) {
      provider.refresh();
      tags = update;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      controller: provider,
      appBarBuilder: (context) => DefaultAppBar(
        title: Text('Following'),
        actions: [
          ContextDrawerButton(),
        ],
      ),
      drawerActions: [
        FollowSplitSwitchTile(),
        FollowSettingsTile(),
      ],
    );
  }
}
