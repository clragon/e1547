import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppIcon extends StatelessWidget {
  final double radius;

  const AppIcon({this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      width: radius * 2,
      height: radius * 2,
      child: Image.asset('assets/icon/round.png'),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBarWidget() {
      return DefaultAppBar(
        title: Text('About'),
        leading: BackButton(),
        actions: [
          VersionButton(),
        ],
      );
    }

    Widget body() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppIcon(radius: 64),
                        Padding(
                          padding: EdgeInsets.only(top: 24, bottom: 12),
                          child: Text(
                            appInfo.appName,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Text(
                          appInfo.version,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              color: Theme.of(context).cardColor,
              elevation: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appInfo.github != null)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.github),
                      onPressed: () =>
                          launch('https://github.com/' + appInfo.github!),
                    ),
                  if (appInfo.discord != null)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.discord),
                      onPressed: () => launch(
                          'https://discord.com/invite/' + appInfo.discord!),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: appBarWidget(),
      body: body(),
    );
  }
}

class VersionButton extends StatefulWidget {
  const VersionButton();

  @override
  _VersionButtonState createState() => _VersionButtonState();
}

class _VersionButtonState extends State<VersionButton> {
  Future<List<AppVersion>?> newVersions = getNewVersions();

  Future<void> versionDialog(List<AppVersion>? versions) async {
    Future<void> dialog(Widget message, List<Widget>? actions) async {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(appInfo.appName),
          content: message,
          actions: actions,
        ),
      );
    }

    if (versions == null) {
      return dialog(
        Text('Failed to retrieve version information'),
        [
          TextButton(
            child: Text('OK'),
            onPressed: Navigator.of(context).maybePop,
          )
        ],
      );
    }
    if (versions.isEmpty) {
      return dialog(
        Text('You have the newest version (${appInfo.version})'),
        [
          TextButton(
            child: Text('OK'),
            onPressed: Navigator.of(context).maybePop,
          )
        ],
      );
    } else {
      return dialog(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A newer version is available: ',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.5),
                  ),
                ),
                ...versions
                    .map(
                      (release) => [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${release.name} (${release.version})',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Text(release.description!),
                      ],
                    )
                    .reduce((a, b) => [...a, ...b]),
              ],
            ),
          ),
        ),
        [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('DOWNLOAD'),
            onPressed: () => launch(
                'https://github.com/' + appInfo.github! + '/releases/latest'),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) => SafeCrossFade(
        showChild: snapshot.connectionState == ConnectionState.done,
        builder: (context) => Stack(
          children: [
            IconButton(
              icon: Icon(Icons.update),
              onPressed: () => versionDialog(snapshot.data),
            ),
            if (snapshot.data?.isNotEmpty ?? false)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              )
          ],
        ),
        secondChild: CircularProgressIndicator(),
      ),
    );
  }
}
