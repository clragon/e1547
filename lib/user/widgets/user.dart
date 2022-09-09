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
  final User user;
  final UserPageSection initialPage;

  const UserPage({
    required this.user,
    this.initialPage = UserPageSection.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return _UserPageProvider(
      user: user,
      child: Consumer<_UserPageControllers>(
        builder: (context, controllers, child) {
          Map<Widget, Widget> tabs = {
            const Tab(text: 'Favorites'): PostGrid(
              controller: controllers.favoritePosts,
            ),
            const Tab(text: 'Uploads'): PostGrid(
              controller: controllers.uploadedPosts,
            ),
            const Tab(text: 'About'): UserInfo(user: user),
          };

          return DefaultTabController(
            length: tabs.length,
            initialIndex: initialPage.index,
            child: ListenableListener(
              listener: () async {
                await controllers.profilePost?.waitForFirstPage();
                await context.read<HistoriesService>().addUser(
                      user,
                      avatar: controllers.profilePost?.itemList?.first,
                    );
              },
              listenable: Listenable.merge([controllers.profilePost]),
              child: Scaffold(
                drawer: const NavigationDrawer(),
                endDrawer: ContextDrawer(
                  title: const Text('Posts'),
                  children: [
                    DrawerMultiDenySwitch(controllers: controllers.all),
                    DrawerMultiTagCounter(controllers: controllers.all),
                  ],
                ),
                body: NestedScrollView(
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
                      child: TabBarView(
                        children: tabs.values.toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
                    controller: avatar,
                    enabled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.headline6,
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
  final User user;

  const UserInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    Widget info(IconData icon, String title, String value,
        {VoidCallback? onLongPress}) {
      return UserInfoTile(
        icon: icon,
        title: title,
        value: value,
        onLongPress: onLongPress,
      );
    }

    return ListView(
      padding:
          defaultActionListPadding.add(LimitedWidthLayout.of(context).padding),
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
  final String value;
  final String title;
  final IconData icon;
  final VoidCallback? onLongPress;
  final double maxWidth;

  const UserInfoTile({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    this.onLongPress,
    this.maxWidth = 500,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= maxWidth) {
        return IconTheme(
          data: const IconThemeData(
            color: Colors.grey,
          ),
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: DefaultTextStyle(
              style: Theme.of(context).textTheme.subtitle1!,
              child: InkWell(
                onLongPress: onLongPress,
                child: Text(value),
              ),
            ),
          ),
        );
      } else {
        return IconTheme(
          data: const IconThemeData(
            color: Colors.grey,
          ),
          child: ListTile(
            leading: Icon(icon),
            title: Text(value),
            subtitle: Text(title),
            onLongPress: onLongPress,
          ),
        );
      }
    });
  }
}
