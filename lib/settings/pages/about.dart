import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar appBarWidget() {
      return AppBar(
        title: Text('About'),
        leading: BackButton(),
        actions: <Widget>[
          FutureBuilder(
            future: getNewVersions(),
            builder: (context, AsyncSnapshot<List<AppVersion>> snapshot) {
              return SafeCrossFade(
                showChild: snapshot.hasData,
                child: (BuildContext context) {
                  return Stack(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () {
                          Widget msg;
                          List<Widget> actions = [];
                          if (snapshot.data.length == 0) {
                            msg = Text(
                                "You have the newest version ($appVersion)");
                            actions.add(TextButton(
                              child: Text("OK"),
                              onPressed: Navigator.of(context).maybePop,
                            ));
                          } else {
                            msg = ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
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
                                            .bodyText1
                                            .color
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    ...snapshot.data
                                        .map(
                                          (release) => [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              child: Text(
                                                '${release.name} (${release.version})',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ),
                                            Text(release.description),
                                          ],
                                        )
                                        .reduce((a, b) => [...a, ...b]),
                                  ],
                                ),
                              ),
                            );
                            actions.addAll([
                              TextButton(
                                child: Text("CANCEL"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("DOWNLOAD"),
                                onPressed: () => launch('https://github.com/' +
                                    github +
                                    '/releases/latest'),
                              )
                            ]);
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(appName),
                                content: msg,
                                actions: actions,
                              );
                            },
                          );
                        },
                      ),
                      if (snapshot.data.length != 0)
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
                  );
                },
                secondChild: IconButton(
                  icon: Icon(Icons.update),
                  onPressed: () => launch('https://github.com/' + github),
                ),
              );
            },
          )
        ],
      );
    }

    Widget body() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Row(children: [
            Flexible(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/icon/paw.png'),
                      radius: 44.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24, bottom: 12),
                      child: Text(
                        appName,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Text(
                      appVersion,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ]),
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
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.github),
                        onPressed: () =>
                            launch('https://github.com/' + github)),
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.discord),
                        onPressed: () =>
                            launch('https://discord.com/invite/' + discord)),
                  ],
                ),
              )),
        ],
      );
    }

    return Scaffold(
      appBar: appBarWidget(),
      body: body(),
    );
  }
}

Future<List<AppVersion>> getNewVersions() async {
  List<AppVersion> releases = await getVersions();
  AppVersion current = AppVersion(version: appVersion);
  return releases
      .where((AppVersion release) => release.compareTo(current) == 1)
      .toList();
}

List<AppVersion> githubData = [];

Future<List<AppVersion>> getVersions() async {
  if (kReleaseMode) {
    if (githubData.length == 0) {
      Dio dio = Dio(BaseOptions(
        baseUrl: 'https://api.github.com/',
        sendTimeout: 30000,
        connectTimeout: 30000,
      ));
      dio.transformer = FlutterTransformer();
      try {
        dio.get('repos/$github/releases').then(
          (response) {
            for (Map release in response.data) {
              githubData.add(
                AppVersion(
                    version: release['tag_name'],
                    name: release['name'],
                    description: release['body']),
              );
            }
          },
        );
      } on DioError {
        // failed to get github data
      }
    }
  }
  return githubData;
}

class AppVersion extends Comparable<AppVersion> {
  int major;
  int minor;
  int patch;

  String name;
  String description;
  String version;

  AppVersion({
    @required this.version,
    this.name,
    this.description,
  }) {
    if (version[0] == 'v') {
      version = version.substring(1);
    }
    List<String> parts = version.split('.');
    try {
      major = int.tryParse(parts[0]);
      minor = int.tryParse(parts[1]) ?? 0;
      patch = int.tryParse(parts[2]) ?? 0;
    } catch (_) {
      major = 0;
      minor = 0;
      patch = 0;
    }
  }

  @override
  int compareTo(AppVersion other) {
    int majorDelta = this.major.compareTo(other.major);
    if (majorDelta != 0) {
      return majorDelta;
    }
    int minorDelta = this.minor.compareTo(other.minor);
    if (minorDelta != 0) {
      return minorDelta;
    }
    int patchDelta = this.patch.compareTo(other.patch);
    if (patchDelta != 0) {
      return patchDelta;
    }
    return 0;
  }
}
