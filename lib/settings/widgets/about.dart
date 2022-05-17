import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:store_checker/store_checker.dart';

class AppIcon extends StatelessWidget {
  final double radius;

  const AppIcon({this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle),
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
      appBar: const DefaultAppBar(
        title: Text('About'),
        leading: BackButton(),
        actions: [NewVersionsButton()],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(radius: 64),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      appInfo.appName,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Text(
                    appInfo.version,
                    style: const TextStyle(
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
              shape: const RoundedRectangleBorder(
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
                        icon: const FaIcon(FontAwesomeIcons.github),
                        onPressed: () =>
                            launch('https://github.com/${appInfo.github!}'),
                      ),
                    if (appInfo.discord != null)
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.discord),
                        onPressed: () => launch(
                            'https://discord.com/invite/${appInfo.discord!}'),
                      ),
                    if (Platform.isAndroid) const PlaystoreButton(),
                    if (appInfo.website != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.globe),
                          onPressed: () =>
                              launch('https://${appInfo.website!}'),
                        ),
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

class NewVersionsButton extends StatefulWidget {
  const NewVersionsButton();

  @override
  State<NewVersionsButton> createState() => _NewVersionsButtonState();
}

class _NewVersionsButtonState extends State<NewVersionsButton> {
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
              icon: const Icon(Icons.update),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        secondChild: const CircularProgressIndicator(),
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
        onPressed: Navigator.of(context).maybePop,
        child: const Text('OK'),
      )
    ];

    if (newVersions == null) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          IconMessage(
            title: Text('Failed to retrieve version information'),
            icon: Icon(Icons.warning_amber),
          ),
        ],
      );
    } else if (newVersions!.isEmpty) {
      body = Text('You have the newest version (${appInfo.version})');
    } else {
      body = SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('DOWNLOAD'),
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

class PlaystoreButton extends StatefulWidget {
  const PlaystoreButton();

  @override
  State<PlaystoreButton> createState() => _PlaystoreButtonState();
}

class _PlaystoreButtonState extends State<PlaystoreButton> {
  Future<Source> source = StoreChecker.getSource;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Source>(
      future: source,
      builder: (context, snapshot) => CrossFade.builder(
        showChild: snapshot.hasData &&
            snapshot.data != Source.IS_INSTALLED_FROM_PLAY_STORE,
        builder: (context) => IconButton(
          icon: const Padding(
            padding: EdgeInsets.only(left: 3),
            child: FaIcon(FontAwesomeIcons.googlePlay),
          ),
          onPressed: () => launch(
            'https://play.google.com/store/apps/details?id=${appInfo.packageName}',
          ),
        ),
      ),
    );
  }
}

class DrawerUpdateIcon extends StatefulWidget {
  @override
  State<DrawerUpdateIcon> createState() => _DrawerUpdateIconState();
}

class _DrawerUpdateIconState extends State<DrawerUpdateIcon> {
  Future<List<AppVersion>?> newVersions = getNewVersions();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Stack(
            children: [
              const Icon(Icons.update),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Icon(Icons.info);
        }
      },
    );
  }
}
