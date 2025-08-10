import 'dart:async';
import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late AppInfoClient? client;

  late Future<List<AppVersion>>? versions = client?.getNewVersions();
  late Future<List<Donor>>? bundledDonors = client?.getBundledDonors();
  late Future<List<Donor>>? donors = client?.getDonors();

  @override
  void didChangeDependencies() {
    client = context.read<AppInfoClient?>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(
        child: DefaultAppBar(leading: CloseButton()),
      ),
      body: RefreshablePage(
        refresh: (refreshController) async {
          try {
            setState(() {
              versions = client?.getNewVersions(force: true);
              bundledDonors = client?.getBundledDonors();
              donors = client?.getDonors(force: true);
            });
            await versions;
            await bundledDonors;
            await donors;
            refreshController.refreshCompleted();
          } on AppUpdaterException {
            refreshController.refreshFailed();
          }
        },
        builder: (context, child) => LimitedWidthLayout(child: child),
        child: (context) => ListView(
          padding: LimitedWidthLayout.of(context).padding,
          children: [
            const SizedBox(height: 100),
            const DevOptionEnabler(child: AboutLogo()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                child: Column(
                  children: [
                    AboutVersion(newVersions: versions),
                    const AboutLinks(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                child: AboutDonations(
                  bundledDonors: bundledDonors,
                  donors: donors,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DevOptionEnabler extends StatefulWidget {
  const DevOptionEnabler({super.key, required this.child});

  final Widget child;

  @override
  State<DevOptionEnabler> createState() => _DevOptionEnablerState();
}

class _DevOptionEnablerState extends State<DevOptionEnabler> {
  int taps = 0;
  Timer? reset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final messenger = ScaffoldMessenger.of(context);
        reset?.cancel();
        setState(() => taps++);
        if (taps == 7) {
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text('You are now a developer!'),
            ),
          );
          context.read<Settings>().showDev.value = true;
          taps = 0;
        }
        reset = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => taps = 0);
        });
      },
      child: widget.child,
    );
  }
}

class AboutLogo extends StatelessWidget {
  const AboutLogo({super.key});

  @override
  Widget build(BuildContext context) {
    AppInfo appInfo = AppInfo.instance;
    return SizedBox(
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
                style: const TextStyle(fontSize: 22),
              ),
            ),
            Text(appInfo.version, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class AboutVersion extends StatelessWidget {
  // ignore: unused_element
  const AboutVersion({super.key, required this.newVersions});

  final Future<List<AppVersion>>? newVersions;

  @override
  Widget build(BuildContext context) {
    void openGithub() {
      AppInfoClient? updater = context.read<AppInfoClient?>();
      if (updater == null) return;
      launch(updater.latestReleaseUrl());
    }

    Widget changesDialog(List<AppVersion> versions) {
      return AlertDialog(
        title: Text(AppInfo.instance.appName),
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
          TextButton(onPressed: openGithub, child: const Text('DOWNLOAD')),
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
                  title: const Text('Version'),
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

class AboutLinks extends StatelessWidget {
  const AboutLinks({super.key});

  @override
  Widget build(BuildContext context) {
    AppInfo appInfo = AppInfo.instance;

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

    return Column(
      children: [
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
        if (appInfo.kofi != null &&
            ![
              Source.IS_INSTALLED_FROM_PLAY_STORE,
              Source.IS_INSTALLED_FROM_APP_STORE,
            ].contains(appInfo.source))
          linkListTile(
            leading: const FaIcon(FontAwesomeIcons.mugSaucer),
            title: const Text('Ko-fi'),
            link: 'https://ko-fi.com/',
            extra: appInfo.kofi,
          ),
        if (appInfo.email != null)
          linkListTile(
            leading: const FaIcon(FontAwesomeIcons.solidEnvelope),
            title: const Text('Email'),
            link: 'mailto:',
            extra: appInfo.email,
          ),
        const Divider(),
        linkListTile(
          leading: const FaIcon(FontAwesomeIcons.googlePlay),
          title: const Text('Playstore'),
          link: Platform.isAndroid
              ? 'https://play.google.com/store/apps/details?id='
              : 'https://play.google.com/store/search?q=',
          extra: AppInfo.instance.packageName,
        ),
      ],
    );
  }
}

class AboutDonations extends StatelessWidget {
  const AboutDonations({super.key, this.bundledDonors, this.donors});

  final Future<List<Donor>>? bundledDonors;
  final Future<List<Donor>>? donors;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: bundledDonors,
      builder: (context, assetDonations) => FutureBuilder(
        future: donors,
        builder: (context, githubDonations) {
          List<Donor>? donors;

          if (githubDonations.hasData) {
            donors = githubDonations.data;
          } else if (assetDonations.hasData) {
            donors = assetDonations.data;
          }

          if (githubDonations.hasError && assetDonations.hasError) {
            return const IconMessage(
              icon: Icon(Icons.warning_amber),
              title: Text('Failed to fetch donors'),
            );
          }

          if (donors?.isEmpty ?? false) {
            return const SizedBox();
          }

          return Column(
            children: [
              const ListTile(
                title: Text('Donors'),
                leading: FaIcon(FontAwesomeIcons.handHoldingHeart),
                subtitle: Text('Thanks for helping me keep up development!'),
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (donors == null ||
                  (bundledDonors == null && this.donors == null))
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (donors.isEmpty)
                // I dont like whining about no donors
                const ListTile(
                  title: Text('No donors yet'),
                  leading: FaIcon(FontAwesomeIcons.heartCrack),
                )
              else
                Donors(donors: donors),
            ],
          );
        },
      ),
    );
  }
}

class DrawerUpdateIcon extends StatelessWidget {
  const DrawerUpdateIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SubFuture<List<AppVersion>>(
      create: () =>
          context.read<AppInfoClient?>()?.getNewVersions() ?? Future.value([]),
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
