import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String? tags;
  final bool reversePools;

  const SearchPage({this.tags, this.reversePools = false});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with ListenerCallbackMixin {
  late bool reversePools = widget.reversePools;
  bool loading = true;
  Pool? pool;

  late PostController controller = PostController(
    search: widget.tags,
    provider: (tags, page, force) => client.posts(
      page,
      search: tags,
      reversePools: reversePools,
      force: force,
    ),
  );

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        controller.search: updatePool,
        settings.follows: updateFollow,
        controller: updateFollow,
      };

  String getTitle() {
    Follow? follow = settings.follows.value
        .singleWhereOrNull((follow) => follow.tags == controller.search.value);
    if (follow != null) {
      return follow.title;
    }
    if (pool != null) {
      return tagToTitle(pool!.name);
    }
    if (Tagset.parse(controller.search.value).length == 1) {
      return tagToTitle(controller.search.value);
    }
    return 'Search';
  }

  Future<void> updateFollow() async {
    List<Follow> follows = List.from(settings.follows.value);
    Follow? follow = follows.singleWhereOrNull(
      (follow) => follow.tags == controller.search.value,
    );
    if (follow != null) {
      if (controller.itemList?.isNotEmpty ?? false) {
        bool updated = await follow.updateLatest(
          client.host,
          controller.itemList!.first,
          foreground: true,
        );
        if (updated) {
          settings.follows.value = follows;
        }
      }
      if (pool != null) {
        if (follow.updatePool(pool!)) {
          settings.follows.value = follows;
        }
      }
    }
  }

  Future<void> updatePool() async {
    setState(() {
      loading = true;
    });
    Tagset input = Tagset.parse(controller.search.value);
    RegExpMatch? match = poolRegex().firstMatch(input.toString());
    if (input.length == 1 &&
        match != null &&
        match.namedGroup('id')! != pool?.id.toString()) {
      pool = await client.pool(int.parse(match.namedGroup('id')!));
    } else {
      pool = null;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      controller: controller,
      appBarBuilder: (context) => DefaultAppBar(
        title: Text(getTitle()),
        leading: BackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CrossFade(
                  showChild: !loading &&
                      Tagset.parse(controller.search.value).isNotEmpty,
                  child: IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: pool != null
                        ? () => poolSheet(context, pool!)
                        : () => wikiSheet(
                              context: context,
                              tag: controller.search.value,
                              controller: controller,
                            ),
                  ),
                ),
                ContextDrawerButton(),
              ],
            ),
          ),
        ],
      ),
      drawerActions: [
        if (pool != null)
          PoolOrderSwitch(
            reversePool: reversePools,
            onChange: (value) {
              setState(() {
                reversePools = value;
              });
              controller.refresh();
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}
