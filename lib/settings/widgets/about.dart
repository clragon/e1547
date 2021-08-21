import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
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
        actions: [
          VersionButton(),
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
                  children: [
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

class VersionButton extends StatefulWidget {
  const VersionButton();

  @override
  _VersionButtonState createState() => _VersionButtonState();
}

class _VersionButtonState extends State<VersionButton> {
  List<AppVersion>? newVersions;

  @override
  void initState() {
    super.initState();
    getNewVersions().then((value) => setState(() => newVersions = value));
  }

  @override
  Widget build(BuildContext context) {
    return SafeCrossFade(
      showChild: newVersions != null,
      builder: (BuildContext context) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.update),
              onPressed: () {
                Widget msg;
                List<Widget> actions = [];
                if (newVersions!.isEmpty) {
                  msg = Text("You have the newest version ($appVersion)");
                  actions.add(TextButton(
                    child: Text("OK"),
                    onPressed: Navigator.of(context).maybePop,
                  ));
                } else {
                  msg = ConstrainedBox(
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
                          ...newVersions!
                              .map(
                                (release) => [
                                  Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: Text(
                                      '${release.name} (${release.version})',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                  Text(release.description!),
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
                      onPressed: () => launch(
                          'https://github.com/' + github + '/releases/latest'),
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
            if (newVersions!.isNotEmpty)
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
      secondChild: CircularProgressIndicator(),
    );
  }
}
