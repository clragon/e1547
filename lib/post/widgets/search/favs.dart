import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';

import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with RouterDrawerEntryWidget {
  @override
  Widget build(BuildContext context) {
    return FavoritePostsProvider(
      child: Consumer<FavoritePostsController>(
        builder: (context, controller, child) => SubListener(
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            try {
              await controller.waitForFirstPage();
              await service.addPostSearch(
                controller.client.host,
                controller.search.value,
                posts: controller.itemList,
              );
            } on NoUserLoginException {
              // in case of no login, we create no history entry.
            }
          },
          listenable: controller.search,
          child: LoadingPage(
            isEmpty: controller.error is NoUserLoginException,
            isError: controller.error is NoUserLoginException,
            onError: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('You are not logged in'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                  child: const Text('LOGIN'),
                ),
              ],
            ),
            onErrorIcon: const Icon(Icons.login),
            loadingBuilder: (context, child) => AdaptiveScaffold(
              appBar: const DefaultAppBar(title: Text('Favorites')),
              body: Center(child: child(context)),
              drawer: const RouterDrawer(),
            ),
            child: (context) => PostsPage(
              controller: controller,
              appBar: const DefaultAppBar(
                title: Text('Favorites'),
                actions: [ContextDrawerButton()],
              ),
              drawerActions: [
                if (controller.isFavoriteSearch)
                  SwitchListTile(
                    secondary: const Icon(Icons.sort),
                    title: Text(
                      'Favorite order',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(controller.orderFavorites.value
                        ? 'added order'
                        : 'id order'),
                    value: controller.orderFavorites.value,
                    onChanged: (value) {
                      controller.orderFavorites.value = value;
                      Navigator.of(context).maybePop();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
