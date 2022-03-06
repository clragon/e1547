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
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text('About'),
        leading: BackButton(),
        actions: [VersionButton()],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
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
          Positioned(
            bottom: 0,
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
          )
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) => CrossFade.builder(
        showChild: snapshot.connectionState == ConnectionState.done,
        builder: (context) => Stack(
          children: [
            IconButton(
              icon: Icon(Icons.update),
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    NewVersionsDialog(newVersions: snapshot.data),
              ),
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
              ),
          ],
        ),
        secondChild: CircularProgressIndicator(),
      ),
    );
  }
}

class NewVersionsDialog extends StatelessWidget {
  final List<AppVersion>? newVersions;

  const NewVersionsDialog({required this.newVersions});

  @override
  Widget build(BuildContext context) {
    Widget body;
    List<Widget> actions = [
      TextButton(
        child: Text('OK'),
        onPressed: Navigator.of(context).maybePop,
      )
    ];

    if (newVersions == null) {
      body = Text('Failed to retrieve version information');
    } else if (newVersions!.isEmpty) {
      body = Text('You have the newest version (${appInfo.version})');
    } else {
      body = SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A newer version is available: ',
              style: TextStyle(color: dimTextColor(context, 0.5)),
            ),
            ...newVersions!
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
      );
      actions = [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('DOWNLOAD'),
          onPressed: () =>
              launch('https://github.com/${appInfo.github!}/releases/latest'),
        )
      ];
    }

    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: Text(appInfo.appName),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5,
          ),
          child: body,
        ),
        actions: actions,
      ),
    );
  }
}
