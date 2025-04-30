import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/traits/traits.dart';
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
    super.key,
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
                  ChangeNotifierProvider<PostController>.value(
                    value: controllers.favoritePosts,
                    builder: (context, child) => PostSliverDisplay(
                      controller: controllers.favoritePosts,
                    ),
                  ),
              const Tab(text: 'Uploads'): (context) =>
                  ChangeNotifierProvider<PostController>.value(
                    value: controllers.uploadedPosts,
                    builder: (context, child) => PostSliverDisplay(
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
                        children: tabs.values
                            .map(
                              (e) => CustomScrollView(
                                slivers: [
                                  SliverOverlapInjector(
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                      context,
                                    ),
                                  ),
                                  e(context),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              );
              tabs[const Tab(text: 'About')] = (context) => SliverPadding(
                    padding: defaultListPadding
                        .add(LimitedWidthLayout.of(context).padding),
                    sliver: SliverToBoxAdapter(
                      child: UserInfo(
                          user: user, compact: constraints.maxWidth < 600),
                    ),
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
                        child: TabBarView(
                          children: tabs.values
                              .toList()
                              .sublist(0, tabs.length)
                              .map(
                                (e) => CustomScrollView(
                                  slivers: [e(context)],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
              appbar = DefaultAppBar(
                ignoreTitlePointer: false,
                title: TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).iconTheme.color,
                  indicatorColor: Theme.of(context).iconTheme.color,
                  tabs: tabs.keys.toList().sublist(0, tabs.length).toList(),
                ),
                actions: [
                  _UserProfileActions(user: user),
                  const ContextDrawerButton(),
                ],
                elevation: 0,
              );
            }

            return ControllerHistoryConnector<PostController?>(
              controller: controllers.profilePost,
              addToHistory: (context, client, controller) =>
                  client.histories.addUser(
                user: user,
                avatar: controller?.items?.first,
              ),
              child: DefaultTabController(
                length: tabs.length,
                initialIndex: initialPage.index,
                child: Scaffold(
                  appBar: appbar,
                  drawer: const RouterDrawer(),
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
  final PostController? avatar;

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
        _UserProfileActions(user: user),
      ],
    );
  }
}

class _UserProfileActions extends StatelessWidget {
  const _UserProfileActions({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Traits> traits = context.watch<Client>().traits;
    String userTag = 'user:${user.id}';
    bool blocked = traits.value.denylist.contains(userTag);
    return PopupMenuButton<VoidCallback>(
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
        PopupMenuTile(
          title: blocked ? 'Unblock' : 'Block',
          icon: blocked ? Icons.check : Icons.block,
          value: () {
            if (blocked) {
              traits.value = traits.value.copyWith(
                denylist: traits.value.denylist..remove(userTag),
              );
            } else {
              traits.value = traits.value.copyWith(
                denylist: traits.value.denylist..add(userTag),
              );
            }
          },
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

  List<PostController> get all => [
        favoritePosts,
        uploadedPosts,
        if (profilePost != null) profilePost!,
      ];

  final PostController favoritePosts;
  final PostController uploadedPosts;
  final PostController? profilePost;

  void dispose() => all.forEach((e) => e.dispose());
}

class _UserPageProvider extends SubProvider<Client, _UserPageControllers> {
  // ignore: unused_element, unused_element_parameter
  _UserPageProvider({required User user, super.child, super.builder})
      : super(
          create: (context, client) => _UserPageControllers(
            favoritePosts: UserFavoritesController(
              client: client,
              user: user.name,
            ),
            uploadedPosts: UserUploadsController(
              client: client,
              user: user.name,
            ),
            profilePost: user.avatarId != null
                ? SinglePostController(
                    client: client,
                    id: user.avatarId!,
                  )
                : null,
          ),
          dispose: (context, value) => value.dispose(),
        );
}

class UserInfo extends StatelessWidget {
  const UserInfo({super.key, required this.user, this.compact = true});

  final User user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Widget info(
      IconData icon,
      String title,
      Object? value, {
      VoidCallback? onLongPress,
    }) {
      if (value == null) return const SizedBox();
      return UserInfoTile(
        icon: icon,
        title: title,
        value: value.toString(),
        onLongPress: onLongPress,
        compact: compact,
      );
    }

    return Expandables(
      expanded: true,
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.about?.bio case final bio? when bio.isNotEmpty)
              Card(
                child: ExpandablePanel(
                  controller: Expandables.of(context, 'about'),
                  header: const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('About'),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DText(bio),
                  ),
                ),
              ),
            if (user.about?.comission case final comission?
                when comission.isNotEmpty)
              Card(
                child: ExpandablePanel(
                  controller: Expandables.of(context, 'comission'),
                  header: const ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Comission'),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DText(comission),
                  ),
                ),
              ),
            Card(
              child: ExpandablePanel(
                controller: Expandables.of(context, 'info'),
                header: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Info'),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      info(
                        Icons.tag,
                        'id',
                        user.id.toString(),
                        onLongPress: () {
                          Clipboard.setData(
                              ClipboardData(text: user.id.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text('Copied user id #${user.id}'),
                          ));
                        },
                      ),
                      if (user.stats case final stats?) ...[
                        info(
                          Icons.calendar_today,
                          'joined',
                          stats.createdAt != null
                              ? DateFormatting.named(stats.createdAt!)
                              : null,
                        ),
                        info(Icons.shield, 'rank',
                            stats.levelString?.toLowerCase()),
                        info(Icons.upload, 'posts', stats.postUploadCount),
                        info(Icons.edit, 'edits', stats.postUpdateCount),
                        info(Icons.favorite, 'favorites', stats.favoriteCount),
                        info(Icons.comment, 'comments', stats.commentCount),
                        info(Icons.forum, 'forum', stats.forumPostCount),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
