import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';

import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavPage extends StatelessWidget {
  const FavPage();

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FavPage>(
      child: PostsProvider.builder(
        create: (context, client, denylist) => FavoritePostsController(
          client: client,
          denylist: denylist,
        ),
        child: Consumer<PostsController>(
          builder: (context, controller, child) => ControllerHistoryConnector(
            controller: controller,
            addToHistory: (context, service, controller) =>
                service.addPostSearch(
              controller.client.host,
              controller.search,
              posts: controller.items,
            ),
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
                  if (controller.search['tags']?.isEmpty ?? true)
                    SwitchListTile(
                      secondary: const Icon(Icons.sort),
                      title: Text(
                        'Favorite order',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(controller.orderFavorites
                          ? 'added order'
                          : 'id order'),
                      value: controller.orderFavorites,
                      onChanged: (value) {
                        controller.orderFavorites = value;
                        Navigator.of(context).maybePop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
