import 'dart:convert';

import 'package:e1547/appinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as url;

import 'http.dart';

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
              if (snapshot.hasData) {
                return Stack(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.update),
                      onPressed: () {
                        String msg;
                        FlatButton b1;
                        FlatButton b2;
                        if (int.parse(appVersion.replaceAll('.', '')) >=
                            int.parse(snapshot.data.replaceAll('.', ''))) {
                          msg = "You have the newest version ($appVersion)";
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
                          msg =
                              'A newer version is available (${snapshot.data})';
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
                            content: Text(msg),
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
                          int.parse(snapshot.data.replaceAll('.', ''))) {
                        return Positioned(
                          top: 12,
                          right: 12,
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

Future<String> getLatestVersion() {
  return new HttpHelper().get(
      'api.github.com', '/repos/$github/releases/latest',
      query: {}).then((response) {
    return json.decode(response.body)['tag_name'];
  });
}