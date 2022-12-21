import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
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

class UserPage extends StatelessWidget {
  const UserPage({
    required this.user,
    this.initialPage = UserPageSection.favorites,
  });

  final User user;
  final UserPageSection initialPage;

  @override
  Widget build(BuildContext context) {
    return _UserPageProvider(
      user: user,
      child: Consumer<_UserPageControllers>(
        builder: (context, controllers, child) => LayoutBuilder(
          builder: (context, constraints) {
            Widget body;
            PreferredSizeWidget? appbar;
            Map<Widget, WidgetBuilder> tabs = {
              const Tab(text: 'Favorites'): (context) =>
                  ChangeNotifierProvider<PostsController>.value(
                    value: controllers.favoritePosts,
                    builder: (context, child) => postDisplay(
                      context: context,
                      controller: controllers.favoritePosts,
                    ),
                  ),
              const Tab(text: 'Uploads'): (context) =>
                  ChangeNotifierProvider<PostsController>.value(
                    value: controllers.uploadedPosts,
                    builder: (context, child) => postDisplay(
                      context: context,
                      controller: controllers.uploadedPosts,
                    ),
                  ),
            };

            if (constraints.maxWidth < 1100) {
              body = NestedScrollView(
                controller: PrimaryScrollController.of(context),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: UserSliverAppBar(
                      user: user,
                      avatar: controllers.profilePost,
                      tabs: tabs.keys.toList(),
                    ),
                  ),
                ],
                body: LimitedWidthLayout(
                  child: TileLayout(
                    child: Builder(
                      builder: (context) => TabBarView(
                        children: tabs.values.map((e) => e(context)).toList(),
                      ),
                    ),
                  ),
                ),
              );
              tabs[const Tab(text: 'About')] =
                  (context) => SingleChildScrollView(
                        primary: false,
                        padding: defaultListPadding
                            .add(LimitedWidthLayout.of(context).padding),
                        child: UserInfo(
                            user: user, compact: constraints.maxWidth < 600),
                      );
            } else {
              body = Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: ListView(
                      primary: false,
                      padding: defaultListPadding,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: UserAvatar(
                                  id: user.avatarId,
                                  controller: controllers.profilePost,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 32),
                                child: Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        UserInfo(
                          user: user,
                          compact: false,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LimitedWidthLayout(
                      child: TileLayout(
                        child: Builder(
                          builder: (context) => NestedScrollView(
                            controller: PrimaryScrollController.of(context),
                            headerSliverBuilder:
                                (context, innerBoxIsScrolled) => [
                              SliverAppBar(
                                pinned: true,
                                automaticallyImplyLeading: false,
                                actions: const [SizedBox()],
                                flexibleSpace: TabBar(
                                  labelColor: Theme.of(context).iconTheme.color,
                                  indicatorColor:
                                      Theme.of(context).iconTheme.color,
                                  tabs: tabs.keys
                                      .toList()
                                      .sublist(0, tabs.length)
                                      .toList(),
                                ),
                              ),
                            ],
                            body: TabBarView(
                              children: tabs.values
                                  .toList()
                                  .sublist(0, tabs.length)
                                  .map((e) => e(context))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
              appbar = const DefaultAppBar(
                actions: [ContextDrawerButton()],
                elevation: 0,
              );
            }

            return ControllerHistoryConnector<PostsController?>(
              controller: controllers.profilePost,
              addToHistory: (context, service, data) => service.addUser(
                context.read<Client>().host,
                user,
                avatar: data?.itemList?.first,
              ),
              child: DefaultTabController(
                length: tabs.length,
                initialIndex: initialPage.index,
                child: Scaffold(
                  appBar: appbar,
                  drawer: const NavigationDrawer(),
                  endDrawer: ContextDrawer(
                    title: const Text('Posts'),
                    children: [
                      DrawerMultiDenySwitch(controllers: controllers.all),
                      DrawerMultiTagCounter(controllers: controllers.all),
                    ],
                  ),
                  body: body,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserSliverAppBar extends StatelessWidget {
  const UserSliverAppBar({
    super.key,
    required this.user,
    this.tabs,
    this.avatar,
  });

  final User user;
  final List<Widget>? tabs;
  final PostsController? avatar;

  @override
  Widget build(BuildContext context) {
    return DefaultSliverAppBar(
      pinned: true,
      expandedHeight: 250,
      flexibleSpace: Builder(
        builder: (context) {
          FlexibleSpaceBarSettings settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
          double extension = (settings.currentExtent - settings.minExtent) /
              settings.maxExtent;
          double? leadingWidth = context
              .findAncestorWidgetOfExactType<SliverAppBar>()
              ?.leadingWidth;
          return FlexibleSpaceBar(
            titlePadding: leadingWidth != null
                ? EdgeInsets.only(
                    left: leadingWidth + 8,
                    bottom: 16,
                  )
                : null,
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: 1 - (extension * 6).clamp(0, 1),
              child: Text(user.name),
            ),
            background: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: UserAvatar(
                    id: user.avatarId,
                    controller: avatar,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottom: tabs != null
          ? TabBar(
              labelColor: Theme.of(context).iconTheme.color,
              indicatorColor: Theme.of(context).iconTheme.color,
              tabs: tabs!,
            )
          : null,
      actions: [
        PopupMenuButton<VoidCallback>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => value(),
          itemBuilder: (context) => [
            PopupMenuTile(
              title: 'Browse',
              icon: Icons.open_in_browser,
              value: () async => launch(
                context.read<Client>().withHost(user.link),
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
                        user: user,
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
    );
  }
}

class _UserPageControllers {
  _UserPageControllers({
    required this.favoritePosts,
    required this.uploadedPosts,
    this.profilePost,
  });

  List<PostsController> get all => [
        favoritePosts,
        uploadedPosts,
        if (profilePost != null) profilePost!,
      ];

  final PostsController favoritePosts;
  final PostsController uploadedPosts;
  final PostsController? profilePost;

  void dispose() => all.forEach((e) => e.dispose());
}

class _UserPageProvider
    extends SubProvider2<Client, DenylistService, _UserPageControllers> {
  // ignore: unused_element
  _UserPageProvider({required User user, super.child, super.builder})
      : super(
          create: (context, client, denylist) => _UserPageControllers(
            favoritePosts: PostsController(
              client: client,
              denylist: denylist,
              search: 'fav:${user.name}',
              canSearch: false,
            ),
            uploadedPosts: PostsController(
              client: client,
              denylist: denylist,
              search: 'user:${user.name}',
              canSearch: false,
            ),
            profilePost: user.avatarId != null
                ? PostsController.single(
                    client: client,
                    denylist: denylist,
                    id: user.avatarId!,
                  )
                : null,
          ),
          dispose: (context, value) => value.dispose(),
        );
}

class UserInfo extends StatelessWidget {
  const UserInfo({required this.user, this.compact = true});

  final User user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Widget info(
      IconData icon,
      String title,
      String value, {
      VoidCallback? onLongPress,
    }) {
      return UserInfoTile(
        icon: icon,
        title: title,
        value: value,
        onLongPress: onLongPress,
        compact: compact,
      );
    }

    return Column(
      children: [
        info(
          Icons.tag,
          'id',
          user.id.toString(),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: user.id.toString()));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text('Copied user id #${user.id}'),
            ));
          },
        ),
        info(Icons.shield, 'rank', user.levelString.toLowerCase()),
        info(Icons.upload, 'posts', user.postUploadCount.toString()),
        info(Icons.edit, 'edits', user.postUpdateCount.toString()),
        info(Icons.comment, 'comments', user.commentCount.toString()),
        info(Icons.forum, 'forum', user.forumPostCount.toString()),
      ],
    );
  }
}

class UserInfoTile extends StatelessWidget {
  const UserInfoTile({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    this.onLongPress,
    this.compact = true,
  });

  final String value;
  final String title;
  final IconData icon;
  final VoidCallback? onLongPress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(
        color: Colors.grey,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: compact ? Text(value) : Text(title),
        subtitle: compact ? Text(title) : null,
        trailing: compact
            ? null
            : DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!,
                child: InkWell(
                  onLongPress: onLongPress,
                  child: Text(value),
                ),
              ),
        onLongPress: onLongPress,
      ),
    );
  }
}
