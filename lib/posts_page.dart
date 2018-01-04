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
import 'persistence.dart' show db;
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

  bool _offline = false; // If true, the last request has failed.
  String _errorMessage;

  String _username;
  void _onChangeUsername() {
    db.username.value.then((a) {
      setState(() {
        _username = a;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _search();

    db.username.value.then((a) => _username = a);
    db.username.addListener(_onChangeUsername);
  }

  @override
  void dispose() {
    super.dispose();

    db.username.removeListener(_onChangeUsername);
  }

  Future<Null> _search() async {
    _posts = client.posts(await db.tags.value);
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
      String filterType = const {
        'Score': 'score',
        'Favorites': 'favcount',
        'Views': 'views',
      }[selectedFilter];
      assert(filterType != null);

      Tagset tags = await db.tags.value;

      String valueString = tags[filterType];
      int value = valueString == null ? 0 : int.parse(valueString.substring(2));

      int min = await showDialog<int>(
        context: ctx,
        child: new RangeDialog(
          title: filterType,
          value: value,
          max: 500,
        ),
      );

      _log.info('$selectedFilter min value: $min');
      if (min == null) {
        return;
      }

      if (min == 0) {
        tags.remove(filterType);
      } else {
        tags[filterType] = '>=$min';
      }

      db.tags.value = new Future.value(tags);

      _search();
    };
  }

  Future<Null> _onSelectedSortBy(String selectedSort) async {
    String orderType = const {
      'New': 'new',
      'Score': 'score',
      'Favorites': 'favcount',
      'Views': 'views',
    }[selectedSort];
    assert(orderType != null);

    Tagset tags = await db.tags.value;

    if (orderType == 'new') {
      tags.remove('order');
    } else {
      tags['order'] = orderType;
    }

    db.tags.value = new Future.value(tags);

    _search();
  }

  void _onSelectedMoreActions(String selectedAction) {
    if (selectedAction == 'Refresh') {
      _search();
    } else if (selectedAction == 'Copy link') {
      () async {
        Clipboard.setData(new ClipboardData(
          text: (await db.tags.value).url(await db.host.value).toString(),
        ));
      }();
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
        return new DrawerHeader(
            child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            new CircleAvatar(
              backgroundImage: new AssetImage('icons/paw.png'),
              radius: 48.0,
            ),
            _username != null
                ? new Text(_username)
                : new RaisedButton(
                    child: new Text('LOGIN'),
                    onPressed: () => Navigator.popAndPushNamed(ctx, '/login'),
                  ),
          ],
        ));
      }

      return new Drawer(
          child: new ListView(children: [
        headerWidget(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: new Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(ctx, '/settings'),
        ),
        const AboutListTile(icon: const Icon(Icons.help)),
      ]));
    }

    Widget floatingActionButtonWidget() {
      return new FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () async {
            Tagset tags = await db.tags.value;
            String tagString = await Navigator.of(ctx).push(
                new MaterialPageRoute<String>(
                    builder: (ctx) => new TagEntryPage(tags.toString())));

            _log.info('new tagstring: "$tagString"');
            if (tagString != null) {
              db.tags.value = new Future.value(new Tagset.parse(tagString));
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
