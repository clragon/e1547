import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';

import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavPage extends StatelessWidget {
  const FavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FavPage>(
      child: PostsProvider.builder(
        create: (context, client) => FavoritePostsController(client: client),
        child: Consumer<PostsController>(
          builder: (context, controller, child) => ControllerHistoryConnector(
            controller: controller,
            addToHistory: (context, service, controller) =>
                service.addPostSearch(
              controller.query,
              posts: controller.items,
            ),
            child: LoadingPage(
              isEmpty: controller.error is NoUserLoginException,
              isError: controller.error is NoUserLoginException,
              onError: const IconMessage(
                icon: Icon(Icons.person_search),
                title: Text('Favorites are unavailable for anonymous users'),
              ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
