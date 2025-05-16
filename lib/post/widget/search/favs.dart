import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavPage extends StatelessWidget {
  const FavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FavPage>(
      child: PostProvider.builder(
        create: (context, client) => FavoritePostController(client: client),
        child: Consumer<PostController>(
          builder:
              (context, controller, child) => ControllerHistoryConnector(
                controller: controller,
                addToHistory:
                    (context, client, controller) =>
                        client.histories.addPostSearch(
                          query: controller.query,
                          posts: controller.items,
                        ),
                child: LoadingPage(
                  isEmpty: controller.error is NoUserLoginException,
                  isError: controller.error is NoUserLoginException,
                  onError: const IconMessage(
                    icon: Icon(Icons.person_search),
                    title: Text(
                      'Favorites are unavailable for anonymous users',
                    ),
                  ),
                  loadingBuilder:
                      (context, child) => AdaptiveScaffold(
                        appBar: const DefaultAppBar(title: Text('Favorites')),
                        body: Center(child: child(context)),
                        drawer: const RouterDrawer(),
                      ),
                  child:
                      (context) => PostsPage(
                        controller: controller,
                        appBar: const DefaultAppBar(
                          title: Text('Favorites'),
                          actions: [ContextDrawerButton()],
                        ),
                        drawerActions: [
                          if (controller.query['tags']?.isEmpty ?? true)
                            SwitchListTile(
                              secondary: const Icon(Icons.sort),
                              title: Text(
                                'Favorite order',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                controller.orderFavorites
                                    ? 'added order'
                                    : 'id order',
                              ),
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
