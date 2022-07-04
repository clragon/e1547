import 'package:e1547/interface/interface.dart';

import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage>
    with ListenerCallbackMixin, DrawerEntry {
  final FavoritePostsController controller = FavoritePostsController();

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        controller: () async => controller.addToHistory(context),
      };

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => PageLoader(
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
          body: Center(child: child),
          drawer: const NavigationDrawer(),
        ),
        builder: (context) => PostsPage(
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
    );
  }
}
