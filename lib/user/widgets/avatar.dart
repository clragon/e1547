import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

Future<void> initAvatar(BuildContext context) async {
  String? avatar = await client.currentAvatar;
  if (avatar != null) {
    precacheImage(
      CachedNetworkImageProvider(avatar),
      context,
    );
  }
}

class CurrentUserAvatar extends StatefulWidget {
  const CurrentUserAvatar();

  @override
  _CurrentUserAvatarState createState() => _CurrentUserAvatarState();
}

class _CurrentUserAvatarState extends State<CurrentUserAvatar>
    with LinkingMixin {
  Future<String?> avatar = client.currentAvatar;

  void updateAvatar() {
    if (mounted) {
      setState(() {
        avatar = client.currentAvatar;
      });
    }
  }

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        settings.credentials: updateAvatar,
        settings.host: updateAvatar,
      };

  @override
  Widget build(BuildContext context) {
    return Avatar(avatar: avatar);
  }
}

class UserAvatar extends StatefulWidget {
  final int id;

  const UserAvatar({required this.id});

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> with LinkingMixin {
  late Future<String?> avatar = getAvatar();

  Future<String?> getAvatar() async =>
      (await client.post(widget.id)).sample.url;

  @override
  Widget build(BuildContext context) {
    return Avatar(avatar: avatar);
  }
}

class Avatar extends StatelessWidget {
  final Future<String?> avatar;

  const Avatar({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: avatar,
      builder: (context, snapshot) => snapshot.hasData
          ? CircleAvatar(
              backgroundImage: (CachedNetworkImageProvider(snapshot.data!)),
            )
          : AppIcon(),
    );
  }
}
