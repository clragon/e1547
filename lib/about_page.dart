import 'dart:convert';

import 'package:e1547/appInfo.dart';
import 'package:e1547/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar appBarWidget() {
      return AppBar(
        title: Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.length != 0) {
                int latest = int.tryParse(
                    snapshot.data[0]['version'].replaceAll('.', '') ?? 0);
                return Stack(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.update),
                      onPressed: () {
                        Widget msg;
                        FlatButton b1;
                        FlatButton b2;
                        if (latest <=
                            int.parse(appVersion.replaceAll('.', ''))) {
                          msg =
                              Text("You have the newest version ($appVersion)");
                          b1 = FlatButton(
                            child: Text("GITHUB"),
                            onPressed: () {
                              url.launch('https://github.com/' + github);
                            },
                          );
                          b2 = FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                        } else {
                          msg = Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: () {
                              List<Widget> releases = [];
                              releases.add(Text(
                                'A newer version is available: ',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ));
                              for (Map release in snapshot.data) {
                                if ((int.tryParse(release['version']
                                            .replaceAll('.', '')) ??
                                        0) >
                                    int.parse(appVersion.replaceAll('.', ''))) {
                                  releases.addAll([
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                      child: Text(
                                        release['title'] +
                                            ' (${release['version']}) ',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(release['description']
                                          .replaceAll('-', '•')),
                                    )
                                  ]);
                                }
                              }
                              return releases;
                            }(),
                          );
                          b1 = FlatButton(
                            child: Text("CANCEL"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                          b2 = FlatButton(
                            child: Text("DOWNLOAD"),
                            onPressed: () {
                              url.launch('https://github.com/' +
                                  github +
                                  '/releases/latest');
                            },
                          );
                        }
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(appName),
                            content: msg,
                            actions: [
                              b1,
                              b2,
                            ],
                          ),
                        );
                      },
                    ),
                    () {
                      if (latest > int.parse(appVersion.replaceAll('.', ''))) {
                        return Positioned(
                          bottom: 20,
                          left: 12,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }(),
                  ],
                );
              } else {
                return IconButton(
                  icon: Icon(Icons.update),
                  onPressed: () async =>
                      url.launch('https://github.com/' + github),
                );
              }
            },
            future: getVersions(),
          )
        ],
      );
    }

    Widget body() {
      return Row(children: [
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
      ]);
    }

    return Scaffold(
      appBar: appBarWidget(),
      body: body(),
    );
  }
}

List<Map> githubData = [];

Future<List<Map>> getVersions() async {
  if (kReleaseMode) {
    if (githubData.length == 0) {
      await HttpHelper().get('api.github.com', '/repos/$github/releases',
          query: {}).then((response) {
        for (Map release in json.decode(response.body)) {
          githubData.add({
            'version': release['tag_name'],
            'title': release['name'],
            'description': release['body'],
          });
        }
      });
    }
    return Future.value(githubData);
  } else {
    return [];
  }
}
