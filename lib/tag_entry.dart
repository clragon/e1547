// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class TagEntryPage extends StatefulWidget {
  final String tags;
  TagEntryPage(String tags) : this.tags = tags + ' ';

  @override
  TagEntryPageState createState() => new TagEntryPageState();
}

class TagEntryPageState extends State<TagEntryPage> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('tags')), body: _buildBody(ctx));
  }

  Widget _buildBody(BuildContext ctx) {
    _controller ??= new TextEditingController(text: widget.tags)
      ..selection = new TextSelection(
        baseOffset: widget.tags.length,
        extentOffset: widget.tags.length,
      );

    Widget tagEntry = new TextField(
        autofocus: true,
        maxLines: 1,
        controller: _controller,
        onSubmitted: (t) => Navigator.of(ctx).pop(t));

    List<Widget> buttons = [
      new FlatButton(
        child: new Text('cancel'),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
      new RaisedButton(
        child: new Text('save'),
        onPressed: () => Navigator.of(ctx).pop(_controller.value.text),
      ),
    ];

    return new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Column(children: <Widget>[
          tagEntry,
          new Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons)
        ]));
  }
}
