import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';

import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return FavoritePostsProvider(
      child: Consumer<FavoritePostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            try {
              await controller.waitForFirstPage();
              await context.read<HistoriesService>().addPostSearch(
                    context.read<Client>().host,
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
            loadingBuilder: (context, child) => Scaffold(
              appBar: const DefaultAppBar(title: Text('Favorites')),
              body: Center(child: child(context)),
              drawer: const NavigationDrawer(),
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
                      style: Theme.of(context).textTheme.subtitle1,
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
