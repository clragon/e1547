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

import 'client.dart' show client;
import 'consts.dart' as consts;
import 'pagination.dart' show LinearPagination;
import 'persistence.dart' as persistence;
import 'post.dart';
import 'range_dialog.dart' show RangeDialog;
import 'tag.dart' show Tagset;
import 'tag_entry.dart' show TagEntryPage;

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => new _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final Logger _log = new Logger('PostsPage');

  LinearPagination<Post> _posts;
  Future<String> _username =
      persistence.getUsername(); // TODO these shouldn't be here
  Future<String> _apiKey = persistence.getApiKey();

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

  Future<Null> _search() async {
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
    } on Exception catch (e) {
      _log.info('Going offline: $e', e);
      setState(() {
        _offline = true;
        _errorMessage = e.toString();
      });
    }

    return more;
  }

  Function _popupMenuButtonItemBuilder(List<String> text) {
    return (ctx) {
      List items = new List(text.length);
      for (int i = 0; i < items.length; i++) {
        String t = text[i];
        items[i] = new PopupMenuItem(child: new Text(t), value: t);
      }
      return items;
    };
  }

  Function _onSelectedFilterBy(BuildContext ctx) {
    return (selectedFilter) async {
      _log.info('selectedFilter: $selectedFilter');

      String filterType = const {
        'Score': 'score',
        'Favorites': 'favcount',
        'Views': 'views',
      }[selectedFilter];
      assert(filterType != null);

      String valueString = _tags[filterType];
      int value = valueString == null ? 0 : int.parse(valueString.substring(2));

      int min = await showDialog<int>(
        context: ctx,
        child: new RangeDialog(
          title: filterType,
          value: value,
          max: 500,
        ),
      );

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
    };
  }

  void _onSelectedSortBy(String selectedSort) {
    String orderType = const {
      'New': 'new',
      'Score': 'score',
      'Favorites': 'favcount',
      'Views': 'views',
    }[selectedSort];
    assert(orderType != null);

    if (orderType == 'new') {
      _tags.remove('order');
    } else {
      _tags['order'] = orderType;
    }
    _search();
  }

  void _onSelectedMoreActions(String selectedAction) {
    if (selectedAction == 'Refresh') {
      _search();
    } else if (selectedAction == 'Copy link') {
      Clipboard.setData(new ClipboardData(
        text: _tags.url(client.host).toString(),
      ));
    } else {
      _log.warning('Unknown action type: "$selectedAction"');
    }
  }

  @override
  Widget build(BuildContext ctx) {
    Widget appBarWidget() {
      Widget filterByWidget() {
        return new PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter by',
          itemBuilder: _popupMenuButtonItemBuilder(
            ['Score', 'Favorites', 'Views'],
          ),
          onSelected: _onSelectedFilterBy(ctx),
        );
      }

      Widget sortByWidget() {
        return new PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by',
          itemBuilder: _popupMenuButtonItemBuilder(
            ['New', 'Score', 'Favorites', 'Views'],
          ),
          onSelected: _onSelectedSortBy,
        );
      }

      Widget moreActionsWidget() {
        return new PopupMenuButton<String>(
          tooltip: 'More actions',
          itemBuilder: _popupMenuButtonItemBuilder(
            ['Refresh', 'Copy link'],
          ),
          onSelected: _onSelectedMoreActions,
        );
      }

      return new AppBar(
        title: new Text(consts.appName),
        actions: [
          filterByWidget(),
          sortByWidget(),
          moreActionsWidget(),
        ],
      );
    }

    Widget bodyWidget() {
      if (_offline) {
        return new Container(
            padding: const EdgeInsets.all(50.0),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off),
                  new Divider(),
                  new Text(_errorMessage, textAlign: TextAlign.center),
                ]));
      }

      if (_posts == null) {
        return new Center(child: const Icon(Icons.refresh));
      }

      return new PostGrid(_posts.elements, onLoadMore: _loadNextPage);
    }

    Widget drawerWidget() {
      Widget headerWidget() {
        return new FutureBuilder(
          future: _username,
          builder: (ctx, snapshot) {
            return new DrawerHeader(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  new CircleAvatar(
                    backgroundImage: new AssetImage('icons/paw.png'),
                    radius: 48.0,
                  ),
                  snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null
                      ? new Text(snapshot.data)
                      : new RaisedButton(
                          child: new Text('LOGIN'),
                          onPressed: () async {
                            await Navigator.popAndPushNamed(ctx, '/login');
                            setState(() {
                              _username = persistence.getUsername();
                              _apiKey = persistence.getApiKey();

                              _username.then((u) => client.username = u);
                              _apiKey.then((a) => client.apiKey = a);
                            });
                          },
                        ),
                ]));
          },
        );
      }

      return new Drawer(
          child: new ListView(children: [
        headerWidget(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: new Text('Settings'),
          onTap: () async {
            await Navigator.popAndPushNamed(ctx, '/settings');
            setState(() {
              // TODO: See if we can DRY this with pop...'/login')
              // And don't even do this data wrangling here...
              _username = persistence.getUsername();
              _apiKey = persistence.getApiKey();

              _username.then((u) => client.username = u);
              _apiKey.then((a) => client.apiKey = a);
            });
          },
        ),
        const AboutListTile(icon: const Icon(Icons.help)),
      ]));
    }

    Widget floatingActionButtonWidget() {
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

    return new Scaffold(
      appBar: appBarWidget(),
      body: bodyWidget(),
      drawer: drawerWidget(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
