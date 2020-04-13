import 'dart:convert';

import 'package:e1547/appinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as url;

import 'http.dart';
import 'package:flutter/foundation.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar appBarWidget() {
      return new AppBar(
        title: new Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          new FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data['version'] != null) {
                return Stack(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.update),
                      onPressed: () {
                        Widget msg;
                        FlatButton b1;
                        FlatButton b2;
                        if (int.parse(appVersion.replaceAll('.', '')) >=
                            int.parse(snapshot.data['version'].replaceAll('.', ''))) {
                          msg = Text("You have the newest version ($appVersion)");
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
                              children: <Widget>[
                                Text(
                                  'A newer version is available: ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text(
                                    snapshot.data['title'] + ' (${snapshot.data['version']}) ',
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(snapshot.data['description'].replaceAll('-', '•')),
                                )
                              ],
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
                      if (int.parse(appVersion.replaceAll('.', '')) <
                          int.parse(snapshot.data['version'].replaceAll('.', ''))) {
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
            future: getLatestVersion(),
          )
        ],
      );
    }

    Widget body() {
      return new Row(children: [
        new Flexible(
          child: new Center(
              child: new Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const CircleAvatar(
                  backgroundImage: const AssetImage('assets/icon/paw.png'),
                  radius: 44.0,
                ),
                new Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 12),
                  child: const Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
                const Text(
                  appVersion,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )),
        ),
      ]);
    }

    return new Scaffold(
      appBar: appBarWidget(),
      body: body(),
    );
  }
}

Map githubData;

Future<Map> getLatestVersion() async {
  if (kReleaseMode) {
    if (githubData == null) {
      await new HttpHelper().get(
          'api.github.com', '/repos/$github/releases/latest',
          query: {}).then((response) {
        Map raw = json.decode(response.body);
        githubData = {
          'version': raw['tag_name'],
          'title': raw['name'],
          'description': raw['body'],
        };
      });
    }
    return Future.value(githubData);
  } else {
    return {};
  }
}
