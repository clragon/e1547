import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage();

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> with LinkingMixin {
  bool orderFavorites = false;
  PostController? controller;
  bool error = false;

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.credentials: updateUsername,
      };

  Future<void> updateUsername() async {
    Credentials? credentials = await settings.credentials.value;
    if (credentials != null) {
      setState(() {
        controller = PostController(
          provider: (tags, page) =>
              client.posts(tags, page, orderFavorites: orderFavorites),
          search: 'fav:${credentials.username}',
          canDeny: false,
        );
        error = false;
      });
    } else {
      setState(() {
        error = true;
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
    return PageLoader(
      builder: (context) => PostsPage(
        appBarBuilder: defaultAppBarBuilder('Favorites'),
        controller: controller!,
        drawerActions: [
          if (controller != null)
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
      isBuilt: controller != null,
      isError: error,
      onError: Text('You are not logged in'),
    );
  }
}
