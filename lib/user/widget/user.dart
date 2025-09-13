import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

enum UserPageSection { favorites, uploads, info }

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
    final domain = context.watch<Domain>();
    return FilterControllerProvider(
      create: (_) => PostFilter(domain),
      keys: (_) => [domain],
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget body;
          PreferredSizeWidget? appbar;
          Map<Widget, WidgetBuilder> tabs = {
            const Tab(text: 'Favorites'): (context) => ListenableProvider(
              create: (_) => PostParams()..addTag('fav:${user.name}'),
              child: const SliverPostList(),
            ),
            const Tab(text: 'Uploads'): (context) => ListenableProvider(
              create: (_) => PostParams()..addTag('user:${user.name}'),
              child: const SliverPostList(),
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
                                  handle:
                                      NestedScrollView.sliverOverlapAbsorberHandleFor(
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
              padding: defaultListPadding.add(
                LimitedWidthLayout.of(context).padding,
              ),
              sliver: SliverToBoxAdapter(
                child: UserInfo(
                  user: user,
                  compact: constraints.maxWidth < 600,
                ),
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
                              child: PostAvatar(id: user.avatarId),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 32,
                              ),
                              child: Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UserInfo(user: user, compact: false),
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
                            .map((e) => CustomScrollView(slivers: [e(context)]))
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
                UserProfileActions(user: user),
                const ContextDrawerButton(),
              ],
              elevation: 0,
            );
          }

          return ItemHistoryConnector<User>(
            item: user,
            getEntry: (context, item) => UserHistoryRequest.item(user: user),
            child: DefaultTabController(
              length: tabs.length,
              initialIndex: initialPage.index,
              child: Scaffold(
                appBar: appbar,
                drawer: const RouterDrawer(),
                endDrawer: const ContextDrawer(
                  title: Text('Posts'),
                  children: [DrawerDenySwitch()],
                ),
                body: body,
              ),
            ),
          );
        },
      ),
    );
  }
}
