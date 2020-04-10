import 'package:e1547/appinfo.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as url;

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
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async => url.launch(github),
          ),
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
