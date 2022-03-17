import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum UserPageSection {
  Favorites,
  Uploads,
  Info,
}

class UserPage extends StatefulWidget {
  final User user;
  final Post? avatar;
  final UserPageSection initialPage;

  const UserPage({
    required this.user,
    this.avatar,
    this.initialPage = UserPageSection.Favorites,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with TickerProviderStateMixin, ListenerCallbackMixin {
  late PostController favoritePostController =
      PostController(search: 'fav:${widget.user.name}', canSearch: false);
  late PostController uploadPostController =
      PostController(search: 'user:${widget.user.name}', canSearch: false);
  late TabController tabController;

  late Post? avatar = widget.avatar;
  late Future<Post?> maybeAvatar;

  Future<Post?> getAvatar() async {
    if (avatar != null) {
      return avatar;
    }
    if (widget.user.avatarId != null) {
      avatar = await client.post(widget.user.avatarId!);
      return avatar;
    }
    return null;
  }

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        settings.customHost: () => maybeAvatar = getAvatar(),
      };

  @override
  void initState() {
    super.initState();
    int index = 0;
    switch (widget.initialPage) {
      case UserPageSection.Favorites:
        index = 0;
        break;
      case UserPageSection.Uploads:
        index = 1;
        break;
      case UserPageSection.Info:
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
    Tab(text: 'Favorites'): PostGrid(
      controller: favoritePostController,
    ),
    Tab(text: 'Uploads'): PostGrid(
      controller: uploadPostController,
    ),
    Tab(text: 'About'): UserInfo(user: widget.user),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      endDrawer: ContextDrawer(
        title: Text('Posts'),
        children: [
          DrawerMultiDenySwitch(
            controllers: [
              favoritePostController,
              uploadPostController,
            ],
          ),
          DrawerMultiCounter(
            controllers: [
              favoritePostController,
              uploadPostController,
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: DefaultSliverAppBar(
              pinned: true,
              leading: BackButton(),
              expandedHeight: 250,
              flexibleSpaceBuilder: (context, collapse) => FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                title: Opacity(
                  opacity: 1 - (collapse * 6).clamp(0, 1),
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
                        child: AvatarLoader(maybeAvatar),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 32),
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
                padding: EdgeInsets.symmetric(horizontal: kContentPadding * 2),
                tabs: tabs.keys.toList(),
              ),
              actions: [
                PopupMenuButton<VoidCallback>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) => value(),
                  itemBuilder: (context) => [
                    PopupMenuTile(
                      title: 'Browse',
                      icon: Icons.open_in_browser,
                      value: () async =>
                          launch(widget.user.url(client.host).toString()),
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
                                avatar: avatar,
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
        data: IconThemeData(
          color: Colors.grey,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(icon),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(tag),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: value,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: BouncingScrollPhysics(),
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
                duration: Duration(seconds: 1),
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
