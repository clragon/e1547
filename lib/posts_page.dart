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

import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'package:logging/logging.dart' show Logger;

import 'consts.dart' as consts;
import 'pagination.dart' show LinearPagination;
import 'persistence.dart' as persistence;
import 'post.dart';
import 'range_dialog.dart' show RangeDialog;
import 'tag.dart' show Tagset;
import 'tag_entry.dart' show TagEntryPage;
import 'client.dart' show client;

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => new _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final Logger _log = new Logger('PostsPage');

  LinearPagination<Post> _posts;

  Tagset _tags; // Tags used for searching for posts.

  bool _offline = false; // If true, the last request has failed.
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    () async {
      _tags = await persistence.getTags();
      _log.info('Loaded tags: $_tags');
      _search();
    }();
  }

  _search() async {
    client.host = await persistence.getHost();
    persistence.setTags(_tags);
    _posts = client.posts(_tags);
    _loadNextPage();
  }

  Future<bool> _loadNextPage() async {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    bool more;

    try {
      more = await _posts.loadNextPage();
      setState(() {});
    } catch (e) {
      _log.info('Going offline: $e', e);
      setState(() {
        _offline = true;
        _errorMessage = e.toString();
      });
    }

    return more;
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: _buildAppBar(ctx),
      body: _buildBody(ctx),
      drawer: _buildDrawer(ctx),
      floatingActionButton: _buildFloatingActionButton(ctx),
    );
  }

  AppBar _buildAppBar(BuildContext ctx) {
    List<Widget> widgets = [];

    widgets.add(new PopupMenuButton<String>(
        icon: const Icon(Icons.filter_list),
        tooltip: 'Filter by',
        itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              new PopupMenuItem(child: new Text('Score'), value: 'score'),
              new PopupMenuItem(
                  child: new Text('Favorites'), value: 'favcount'),
              new PopupMenuItem(child: new Text('Views'), value: 'views'),
            ],
        onSelected: (String filterType) async {
          _log.info('filter type: $filterType');

          String valueString = _tags[filterType];
          int value =
              valueString == null ? 0 : int.parse(valueString.substring(2));

          int min = await showDialog<int>(
              context: ctx,
              child:
                  new RangeDialog(title: filterType, value: value, max: 500));
          _log.info('filter min value: $min');
          if (min == null) {
            return;
          }

          if (min == 0) {
            _tags.remove(filterType);
          } else {
            _tags[filterType] = '>=$min';
          }

          _search();
        }));

    widgets.add(new PopupMenuButton<String>(
        icon: const Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              new PopupMenuItem(child: new Text('New'), value: 'new'),
              new PopupMenuItem(child: new Text('Score'), value: 'score'),
              new PopupMenuItem(
                  child: new Text('Favorites'), value: 'favcount'),
              new PopupMenuItem(child: new Text('Views'), value: 'views'),
            ],
        onSelected: (String orderType) {
          if (orderType == 'new') {
            _tags.remove('order');
          } else {
            _tags['order'] = orderType;
          }
          _search();
        }));

    widgets.add(new PopupMenuButton<String>(
        tooltip: 'More actions',
        itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              new PopupMenuItem(
                value: 'refresh',
                child: new Text('Refresh'),
              ),
              new PopupMenuItem(
                value: 'copy',
                child: new Text('Copy link'),
              ),
            ],
        onSelected: (String action) {
          if (action == 'refresh') {
            _search();
          } else if (action == 'copy') {
            Clipboard.setData(
                new ClipboardData(text: _tags.url(client.host).toString()));
          } else {
            _log.warning('Unknown action type: "$action"');
          }
        }));

    return new AppBar(title: new Text(consts.APP_NAME), actions: widgets);
  }

  Widget _buildBody(BuildContext ctx) {
    if (_offline) {
      return new Container(
          padding: const EdgeInsets.all(50.0),
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off),
                const Divider(),
                new Text(_errorMessage, textAlign: TextAlign.center),
              ]));
    }

    if (_posts == null) {
      return new Center(child: const Icon(Icons.refresh));
    }

    return new PostGrid(_posts.elements, onLoadMore: _loadNextPage);
  }

  Widget _buildDrawer(BuildContext ctx) {
    return new Drawer(
        child: new ListView(children: [
      new DrawerHeader(
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
            const CircleAvatar(
              backgroundImage: const AssetImage('icons/paw.png'),
              radius: 48.0,
            ),
            new RaisedButton(
                child: const Text('sign in'),
                onPressed: () {
                  _log.fine('Pressed sign in button');
                }),
          ])),
      new ListTile(
          leading: const Icon(Icons.settings),
          title: new Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(ctx, '/settings')),
      new AboutListTile(icon: const Icon(Icons.help)),
    ]));
  }

  Widget _buildFloatingActionButton(BuildContext ctx) {
    return new FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          String tagString = await Navigator.of(ctx).push(
              new MaterialPageRoute<String>(
                  builder: (ctx) => new TagEntryPage(_tags.toString())));

          _log.fine('edited tags: "$tagString"');
          if (tagString != null) {
            _tags = new Tagset.parse(tagString);
            _search();
          }
        });
  }
}
