import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum UserPageSection {
  favorites,
  uploads,
  info,
}

class UserPage extends StatefulWidget {
  final User user;
  final UserPageSection initialPage;

  const UserPage({
    required this.user,
    this.initialPage = UserPageSection.favorites,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with TickerProviderStateMixin, ListenerCallbackMixin {
  late PostController favoritePostController =
      PostController(search: 'fav:${widget.user.name}', canSearch: false);
  late PostController uploadPostController =
      PostController(search: 'user:${widget.user.name}', canSearch: false);
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    int index = 0;
    switch (widget.initialPage) {
      case UserPageSection.favorites:
        index = 0;
        break;
      case UserPageSection.uploads:
        index = 1;
        break;
      case UserPageSection.info:
        index = 2;
        break;
    }
    tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: index,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    favoritePostController.dispose();
    uploadPostController.dispose();
    super.dispose();
  }

  late Map<Widget, Widget> tabs = {
    const Tab(text: 'Favorites'): PostGrid(
      controller: favoritePostController,
    ),
    const Tab(text: 'Uploads'): PostGrid(
      controller: uploadPostController,
    ),
    const Tab(text: 'About'): UserInfo(user: widget.user),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      endDrawer: ContextDrawer(
        title: const Text('Posts'),
        children: [
          DrawerMultiDenySwitch(
            controllers: [
              favoritePostController,
              uploadPostController,
            ],
          ),
          DrawerMultiTagCounter(
            controllers: [
              favoritePostController,
              uploadPostController,
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: DefaultSliverAppBar(
              pinned: true,
              leading: const BackButton(),
              expandedHeight: 250,
              flexibleSpaceBuilder: (context, extension) => FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                title: Opacity(
                  opacity: 1 - (extension * 6).clamp(0, 1),
                  child: Text(widget.user.name),
                ),
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: GestureDetector(
                        onTap: widget.user.avatarId != null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostLoadingPage(widget.user.avatarId!),
                                  ),
                                )
                            : null,
                        child: PostAvatar(id: widget.user.avatarId),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      child: Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: tabController,
                labelColor: Theme.of(context).iconTheme.color,
                indicatorColor: Theme.of(context).iconTheme.color,
                tabs: tabs.keys.toList(),
              ),
              actions: [
                PopupMenuButton<VoidCallback>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    PopupMenuTile(
                      title: 'Browse',
                      icon: Icons.open_in_browser,
                      value: () async => launch(
                        widget.user.url(client.host).toString(),
                      ),
                    ),
                    PopupMenuTile(
                      title: 'Report',
                      icon: Icons.report,
                      value: () => guardWithLogin(
                        context: context,
                        callback: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserReportScreen(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        error: 'You must be logged in to report users!',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        body: LimitedWidthLayout(
          child: TileLayout(
            child: TabBarView(
              controller: tabController,
              children: tabs.values.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    Widget info(IconData icon, String tag, Widget value) {
      return IconTheme(
        data: const IconThemeData(
          color: Colors.grey,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(icon),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(tag),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: value,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding:
          defaultActionListPadding.add(LimitedWidthLayout.of(context)!.padding),
      children: [
        info(
          Icons.tag,
          'id',
          InkWell(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: user.id.toString()));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content: Text('Copied user id #${user.id}'),
              ));
            },
            child: Text('#${user.id}'),
          ),
        ),
        info(Icons.shield, 'rank', Text(user.levelString.toLowerCase())),
        info(Icons.upload, 'posts', Text(user.postUploadCount.toString())),
        info(Icons.edit, 'edits', Text(user.postUpdateCount.toString())),
        info(Icons.comment, 'comments', Text(user.commentCount.toString())),
        info(Icons.forum, 'forum', Text(user.forumPostCount.toString())),
      ],
    );
  }
}
