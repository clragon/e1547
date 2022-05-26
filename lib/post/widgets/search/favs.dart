import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage>
    with ListenerCallbackMixin, DrawerEntry {
  bool orderFavorites = false;
  PostController? controller;

  @override
  Map<ChangeNotifier, VoidCallback> get initListeners => {
        client: updateUsername,
      };

  Future<void> addToHistory() async {
    controller!.addToHistory(context);
  }

  void updateUsername() {
    Credentials? credentials = client.credentials;
    if (credentials != null) {
      setState(() {
        controller = PostController(
          provider: (tags, page, force) => client.posts(page,
              search: tags, orderFavorites: orderFavorites, force: force),
          search: 'fav:${credentials.username}',
          denyMode: DenyListMode.unavailable,
        );
        controller!.search.addListener(addToHistory);
        addToHistory();
      });
    } else {
      setState(() {
        controller?.search.removeListener(addToHistory);
        controller?.dispose();
        controller = null;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: client,
      builder: (context, child) => PageLoader(
        isEmpty: controller == null,
        isError: controller == null,
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
        builder: (context) => ValueListenableBuilder<String>(
          valueListenable: controller!.search,
          builder: (context, value, child) => PostsPage(
            controller: controller!,
            appBar: const DefaultAppBar(
              title: Text('Favorites'),
              actions: [ContextDrawerButton()],
            ),
            drawerActions: [
              if (favRegex(client.credentials!.username)
                  .hasMatch(controller!.search.value))
                SwitchListTile(
                  secondary: const Icon(Icons.sort),
                  title: Text(
                    'Favorite order',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  subtitle: Text(orderFavorites ? 'added order' : 'id order'),
                  value: orderFavorites,
                  onChanged: (value) {
                    setState(() {
                      orderFavorites = !orderFavorites;
                    });
                    controller!.refresh();
                    Navigator.of(context).maybePop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
