import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/services/client.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/Gian/AndroidStudioProjects/e1547/lib/settings/settings.dart';

ValueNotifier<String> userName = ValueNotifier(null);
ValueNotifier<String> userAvatar = ValueNotifier(null);

void initUser({BuildContext context}) {
  db.username.value.then((name) {
    userName.value = name;
    if (userName.value != null) {
      client.avatar.then((avatar) {
        userAvatar.value = avatar;
        if (avatar != null && context != null) {
          precacheImage(CachedNetworkImageProvider(avatar), context);
        }
      });
    } else {
      userAvatar.value = null;
    }
  });
}

class ProfileHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileHeaderState();
  }
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    db.username.addListener(initUser);
    initUser();
  }

  @override
  void dispose() {
    super.dispose();
    db.username.removeListener(initUser);
  }

  @override
  Widget build(BuildContext context) {
    Widget userNameWidget() {
      return ValueListenableBuilder(
        valueListenable: userName,
        builder: (context, value, child) {
          if (value != null) {
            return Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  value,
                  style: TextStyle(fontSize: 16.0),
                  overflow: TextOverflow.ellipsis,
                )),
                IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      client.logout();
                      String msg = 'Forgot login details';
                      if (value != null) {
                        msg = msg + ' for $value';
                      }

                      Scaffold.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text(msg),
                      ));
                      Navigator.of(context).pop();
                    })
              ],
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: OutlineButton(
                child: Text('LOGIN'),
                onPressed: () => Navigator.popAndPushNamed(context, '/login'),
              ),
            );
          }
        },
      );
    }

    Widget userAvatarWidget() {
      return ValueListenableBuilder(
        valueListenable: userAvatar,
        builder: (context, value, child) {
          return CircleAvatar(
            backgroundImage: value == null
                ? AssetImage('assets/icon/app/paw.png')
                : CachedNetworkImageProvider(value),
            radius: 36.0,
          );
        },
      );
    }

    return Container(
        height: 140,
        child: DrawerHeader(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            userAvatarWidget(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: userNameWidget(),
              ),
            ),
          ],
        )));
  }
}
