import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with LinkingMixin {
  bool orderFavorites = false;
  bool showSwitch = false;
  bool error = false;

  PostController? controller;
  String? username;

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.credentials: updateUsername,
      };

  Future<void> updateSwitch() async {
    setState(() {
      if (controller != null &&
          username != null &&
          favRegex(username!).hasMatch(controller!.search.value)) {
        showSwitch = true;
      } else {
        showSwitch = false;
      }
    });
  }

  Future<void> updateUsername() async {
    Credentials? credentials = settings.credentials.value;
    if (credentials != null) {
      setState(() {
        error = false;
        username = credentials.username;
        controller?.removeListener(updateSwitch);
        controller = PostController(
          provider: (tags, page, force) => client.posts(page,
              search: tags, orderFavorites: orderFavorites, force: force),
          search: 'fav:$username',
          canDeny: false,
        );
        controller!.addListener(updateSwitch);
      });
    } else {
      setState(() {
        error = true;
        username = null;
        controller = null;
      });
    }
  }

  @override
  void dispose() {
    controller?.removeListener(updateSwitch);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLoader(
      isBuilt: controller != null,
      isError: error,
      onError: IconMessage(
          icon: Icon(Icons.login), title: Text('You are not logged in')),
      builder: (context) => PostsPage(
        appBarBuilder: (context) => DefaultAppBar(
          title: Text('Favorites'),
          actions: [
            ContextDrawerButton(),
          ],
        ),
        controller: controller!,
        drawerActions: [
          if (showSwitch)
            SwitchListTile(
              secondary: Icon(Icons.sort),
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
    );
  }
}
