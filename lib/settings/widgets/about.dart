import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AboutPage extends StatefulWidget {
  const AboutPage();

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final RefreshController refreshController = RefreshController();
  late Future<List<AppVersion>> versions =
      context.read<AppInfo>().getNewVersions();

  Widget linkListTile({
    Widget? leading,
    required Widget title,
    required String link,
    String? extra,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: Text(extra ?? link),
      onTap: () => launch(link + (extra ?? '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfo>(
      builder: (context, appInfo, child) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('About'),
          leading: BackButton(),
        ),
        body: RefreshablePage(
          refreshController: refreshController,
          refresh: () async {
            try {
              setState(() {
                versions = context.read<AppInfo>().getNewVersions(force: true);
              });
              await versions;
              refreshController.refreshCompleted();
            } on AppInfoClientException {
              refreshController.refreshFailed();
            }
          },
          builder: (context, child) => LimitedWidthLayout(child: child),
          child: (context) => ListView(
            padding: LimitedWidthLayout.of(context).padding,
            children: [
              SizedBox(
                height: 300,
                child: Center(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Card(
                  child: Column(
                    children: [
                      _VersionTile(newVersions: versions),
                      linkListTile(
                        leading: const FaIcon(FontAwesomeIcons.github),
                        title: const Text('GitHub'),
                        link: 'https://github.com/',
                        extra: appInfo.github,
                      ),
                      linkListTile(
                        leading: const FaIcon(FontAwesomeIcons.discord),
                        title: const Text('Discord'),
                        link: 'https://discord.gg/',
                        extra: appInfo.discord,
                      ),
                      if (appInfo.website != null)
                        linkListTile(
                          leading: const FaIcon(FontAwesomeIcons.house),
                          title: const Text('Website'),
                          link: 'https://',
                          extra: appInfo.website,
                        ),
                      const Divider(),
                      linkListTile(
                        leading: const FaIcon(FontAwesomeIcons.googlePlay),
                        title: const Text('Playstore'),
                        link: Platform.isAndroid
                            ? 'https://play.google.com/store/apps/details?id='
                            : 'https://play.google.com/store/search?q=',
                        extra: context.read<AppInfo>().packageName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionTile extends StatelessWidget {
  // ignore: unused_element
  const _VersionTile({super.key, required this.newVersions});

  final Future<List<AppVersion>> newVersions;

  @override
  Widget build(BuildContext context) {
    void openGithub() => launch(
        'https://github.com/${context.read<AppInfo>().github!}/releases/latest');

    Widget changesDialog(List<AppVersion> versions) {
      return AlertDialog(
        title: Text(context.watch<AppInfo>().appName),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A newer version is available: ',
                  style: TextStyle(color: dimTextColor(context, 0.5)),
                ),
                ...versions
                    .map(
                      (release) => [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${release.name} (${release.version})',
                            style: Theme.of(context).textTheme.titleLarge,
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
        actions: [
          TextButton(
            onPressed: Navigator.of(context).maybePop,
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: openGithub,
            child: const Text('DOWNLOAD'),
          )
        ],
      );
    }

    return FutureBuilder<List<AppVersion>?>(
      future: newVersions,
      builder: (context, snapshot) {
        String message;
        Widget icon;
        VoidCallback? onTap;
        if (snapshot.connectionState != ConnectionState.done) {
          message = 'Fetching updates...';
          icon = const FaIcon(FontAwesomeIcons.clockRotateLeft);
        } else if (snapshot.data == null) {
          message = 'Failed to check for updates';
          onTap = openGithub;
          icon = const FaIcon(FontAwesomeIcons.circleExclamation);
        } else if (snapshot.data!.isEmpty) {
          message = 'You have the newest version';
          icon = const FaIcon(FontAwesomeIcons.clockRotateLeft);
        } else {
          message =
              'A newer version is available: ${snapshot.data!.first.version}';
          onTap = () => showDialog(
                context: context,
                builder: (context) => changesDialog(snapshot.data!),
              );
          icon = const FaIcon(FontAwesomeIcons.download);
        }

        return Column(
          children: [
            Stack(
              fit: StackFit.passthrough,
              children: [
                ListTile(
                  leading: icon,
                  title: const Text('Update'),
                  subtitle: Text(message),
                  onTap: onTap,
                ),
                if (snapshot.data?.isNotEmpty ?? false)
                  Positioned(
                    top: 12,
                    right: 12,
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
            const Divider(),
          ],
        );
      },
    );
  }
}

class DrawerUpdateIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SubFuture<List<AppVersion>>(
      create: () => context.read<AppInfo>().getNewVersions(),
      keys: [context.watch<AppInfo>()],
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
