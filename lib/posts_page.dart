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
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData;

import 'package:logging/logging.dart' show Logger;

import 'persistence.dart' as persistence;
import 'post.dart' show PostPreview;
import 'range_dialog.dart' show RangeDialog;
import 'tag_entry.dart' show TagEntryPage;
import 'vars.dart' as vars;

import 'src/e1547/e1547.dart' show client;
import 'src/e1547/post.dart' show Post;
import 'src/e1547/tag.dart' show Tagset;

const int _STARTING_PAGE = 1; // Pages are 1-indexed

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => new _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final Logger _log = new Logger('PostsPage');

  // Current tags being displayed or searched.
  Tagset _tags;
  // Current posts being displayed.
  List<Post> _posts = [];
  int _page = _STARTING_PAGE;

  // If we're currently offline, meaning a request has failed.
  bool _offline = false;

  @override
  void initState() {
    super.initState();

    _log.info('Performing initial search');
    _loadNextPage();
  }

  _search() {
    persistence.setTags(_tags);
    _page = _STARTING_PAGE;
    _posts.clear();
    _loadNextPage();
  }

  _loadNextPage() async {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    try {
      client.host = await persistence.getHost();
      _tags = _tags ?? await persistence.getTags();
      var newPosts = await client.posts(_tags, _page);
      setState(() {
        _posts.addAll(newPosts);
      });
      _page++;
    } catch (e) {
      _log.info('Going offline: $e', e);
      setState(() {
        _offline = true;
      });
    }
  }

  Widget _itemBuilder(BuildContext ctx, int i) {
    _log.fine('loading post $i');
    if (i < _posts.length) {
      return new PostPreview(_posts[i]);
    } else if (i == _posts.length) {
      return new RaisedButton(
        child: new Text('load more'),
        onPressed: _loadNextPage,
      );
    } else {
      return null;
    }
  }

  Widget _body() {
    if (_offline) {
      return new Center(child: const Icon(Icons.cloud_off));
    }

    if (_posts.isEmpty) {
      return new Center(child: const Icon(Icons.refresh));
    }

    return new GridView.custom(
      gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
        childAspectRatio: 3 / 5,
      ),
      childrenDelegate: new SliverChildBuilderDelegate(_itemBuilder),
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
                  child: new Text('Favorites'), value: 'favorites'),
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
            _tags[filterType] = '>=${min}';
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

    return new AppBar(title: new Text(vars.APP_NAME), actions: widgets);
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
        appBar: _buildAppBar(ctx),
        body: _body(),
        drawer: new Drawer(
            child: new ListView(children: [
          new UserAccountsDrawerHeader(
              // TODO: account name and email
              accountName: new Text('<username>'),
              accountEmail: new Text('<email>'),
              currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.brown.shade800,
                  child: new Text('UU'))),
          new ListTile(
              leading: const Icon(Icons.settings),
              title: new Text('Settings'),
              onTap: () => Navigator.popAndPushNamed(ctx, '/settings')),
          new AboutListTile(icon: const Icon(Icons.help)),
        ])),
        floatingActionButton: new FloatingActionButton(
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
            }));
  }
}
