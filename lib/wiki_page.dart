import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

import 'client.dart';
import 'interface.dart';

void wikiDialog(BuildContext context, String tag, {bool actions = false}) {
  Widget body() {
    return ConstrainedBox(
        child: wikiBody(context, tag),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ));
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            tag.replaceAll('_', ' '),
            softWrap: true,
          ),
        ),
        actions ? TagActions(tag) : Container(),
      ],
    );
  }

  showDialog(
    context: context,
    child: AlertDialog(
      title: title(),
      content: body(),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    ),
  );
}

class TagActions extends StatefulWidget {
  final String tag;

  TagActions(this.tag);

  @override
  State<StatefulWidget> createState() {
    return _TagActionsState();
  }
}

class _TagActionsState extends State<TagActions> {
  bool denied = false;
  bool following = false;
  List<String> denylist;
  List<String> follows;

  Future<void> updateLists() async {
    denylist = await db.denylist.value;
    denied = false;
    denylist.forEach((tag) {
      if (tag == widget.tag) {
        denied = true;
      }
    });
    following = false;
    follows = await db.follows.value;
    follows.forEach((tag) {
      if (tag == widget.tag) {
        following = true;
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(updateLists);
    db.follows.addListener(updateLists);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateLists();
  }

  @override
  void dispose() {
    super.dispose();
    db.denylist.removeListener(updateLists);
    db.follows.removeListener(updateLists);
  }

  @override
  Widget build(BuildContext context) {
    if (follows != null && denylist != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: () {
              if (following) {
                follows.remove(widget.tag);
                db.follows.value = Future.value(follows);
              } else {
                follows.add(widget.tag);
                db.follows.value = Future.value(follows);
                if (denied) {
                  denylist.remove(widget.tag);
                  db.denylist.value = Future.value(denylist);
                }
              }
            },
            icon: crossFade(
              duration: Duration(milliseconds: 200),
              showChild: following,
              child: Icon(Icons.turned_in),
              secondChild: Icon(Icons.turned_in_not),
            ),
            tooltip: following ? 'unfollow tag' : 'follow tag',
          ),
          IconButton(
            onPressed: () {
              if (denied) {
                denylist.remove(widget.tag);
                db.denylist.value = Future.value(denylist);
              } else {
                denylist.add(widget.tag);
                db.denylist.value = Future.value(denylist);
                if (following) {
                  follows.remove(widget.tag);
                  db.follows.value = Future.value(follows);
                }
              }
            },
            icon: crossFade(
              duration: Duration(milliseconds: 200),
              showChild: denied,
              child: Icon(Icons.check),
              secondChild: Icon(Icons.block),
            ),
            tooltip: denied ? 'unblock tag' : 'block tag',
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.block),
            onPressed: () {},
          ),
        ],
      );
    }
  }
}

class WikiWidget extends StatelessWidget {
  final String tag;
  final bool actions;

  const WikiWidget(this.tag, this.actions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Text(
            tag.replaceAll('_', ' '),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          actions ? TagActions(tag) : Container(),
        ],
      ),
      body: wikiBody(context, tag),
    );
  }
}

Widget wikiBody(BuildContext context, String tag) {
  return FutureBuilder(
    builder: (context, snapshot) => crossFade(
        duration: Duration(milliseconds: 200),
        showChild: snapshot.connectionState == ConnectionState.done,
        child: () {
          if (snapshot.data == null) {
            return Text('unable to retrieve wiki entry',
                style: TextStyle(fontStyle: FontStyle.italic));
          }
          if (snapshot.data.length != 0) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: dTextField(context, snapshot.data[0]['body']),
              physics: BouncingScrollPhysics(),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'no wiki entry',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.5),
                      fontStyle: FontStyle.italic),
                )
              ],
            );
          }
        }(),
        secondChild: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(),
                    ))
              ],
            ),
          ],
        )),
    future: client.wiki(tag, 1),
  );
}
