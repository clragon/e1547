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

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart' show StaggeredGridView, StaggeredTile;
import 'package:font_awesome_flutter/font_awesome_flutter.dart' show FontAwesomeIcons;
import 'package:logging/logging.dart' show Logger;
import 'package:meta/meta.dart' show required;
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'consts.dart' as consts;
import 'input.dart' show LowercaseTextInputFormatter;
import 'persistence.dart' show db;
import 'post.dart';
import 'range_dialog.dart' show RangeDialog;
import 'tag.dart' show Tagset;

void _setFocusToEnd(TextEditingController controller) {
  controller.selection = new TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
}

class PostsPage extends StatefulWidget {
  @override
  State createState() => new _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final Logger _log = new Logger('_PostsPageState');

  bool _isEditingTags = false;
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  final Future<TextEditingController> _textEditingControllerFuture = db.tags.value.then((tags) {
    return new TextEditingController()..text = tags.toString() + ' ';
  });

  Function() _onPressedFloatingActionButton(BuildContext ctx) {
    return () async {
      void onCloseBottomSheet() {
        setState(() {
          _isEditingTags = false;
        });
      }

      TextEditingController tagController = await _textEditingControllerFuture;
      _setFocusToEnd(tagController);

      if (_isEditingTags) {
        Tagset newTags = new Tagset.parse(tagController.text);
        _log.info('new tags: $newTags');
        db.tags.value = new Future.value(newTags);

        _bottomSheetController?.close();
        _clearPages();

      } else {
        _bottomSheetController = Scaffold.of(ctx).showBottomSheet(
              (ctx) => new TagEntry(controller: tagController),
        );

        setState(() {
          _isEditingTags = true;
        });

        _bottomSheetController.closed.then((a) => onCloseBottomSheet());
      }
    };
  }

  final List<List<Post>> _pages = [];

  void _loadNextPage() async {
    int p = _pages.length;

    List<Post> nextPage = [];
    _pages.add(nextPage);

    nextPage.addAll(await client.posts(await db.tags.value, p));
    setState(() {});
  }

  void _clearPages() {
    setState(_pages.clear);
  }

  Function() _onPressedChangeColumns(BuildContext ctx) {
    return () async {
      int numColumns = await db.numColumns.value ?? 3;
      int newNumColumns = await showDialog<int>(context: ctx, builder: (ctx) {
        return new RangeDialog(
          title: 'Number of columns',
          value: numColumns,
          max: 10,
          min: 1,
        );
      });

      if (newNumColumns != null && newNumColumns > 0) {
        _log.fine('setting numColumns to $newNumColumns');
        setState(() {
          db.numColumns.value = new Future.value(newNumColumns);
        });
      }
    };
  }

  // Item count is:
  // 1. Total number of loaded posts
  // 2. Header before each page, including a blank header after after the last
  //    page.
  int _itemCount() {
    int i = 0;
    i += _pages.length + 1;
    for (List<Post> p in _pages) {
      i += p.length;
    }
    return i;
  }

  Widget _itemBuilder(BuildContext ctx, int item) {
    Widget postPreview(List<Post> page, int postOnPage, int postOnAll) {
      return new PostPreview(page[postOnPage], onPressed: () {
        Navigator.of(ctx).push(new MaterialPageRoute<Null>(
          builder: (ctx) => new PostSwipe(
              _pages.fold<Iterable<Post>>(const Iterable.empty(),
                      (a, b) => a.followedBy(b)).toList(),
              startingIndex: postOnAll,
          ),
        ));
      });
    }

    Widget pageHeader(String text) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(text),
          const Divider(),
        ],
      );
    }

    _log.finer('building item $item');

    // Special case for first page header.
    if (item == 0) {
      _log.finer('item was first page header');
      if (_pages.isEmpty) {
        _loadNextPage();
        return pageHeader('Loading page 1');
      } else if (_pages[0].isEmpty) {
        return pageHeader('No posts');
      } else {
        return pageHeader('Page 1');
      }
    }

    int i = 1;

    for (int p = 0; p < _pages.length; p++) {
      List<Post> page = _pages[p];
      if (page.isEmpty) {
        return new Container();
      }
      i += page.length;

      if (item < i) {
        _log.finer('item was post on page ${p + 1}');
        return postPreview(page, item-(i-page.length), item-(p+1));
      }

      // Header for next page
      if (item == i) {
        int nextPage = p + 1;
        _log.finer('item was header for page ${nextPage + 1}');
        if (nextPage >= _pages.length) {
          _loadNextPage();
          return pageHeader('Loading page ${nextPage + 1}');
        } else if (_pages[nextPage].isEmpty) {
          return pageHeader('No more posts');
        } else {
          return pageHeader('Page ${nextPage + 1}');
        }
      }
      i += 1;
    }

    _log.finer("couldn't identify item $item");
    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder(int numColumns) {
    return (item) {
      if (item == 0) {
        return new StaggeredTile.extent(numColumns, 50.0);
      }

      int i = 1;
      for (int p = 0; p < _pages.length; p++) {
        List<Post> page = _pages[p];
        i += page.length;

        if (item < i) {
          return const StaggeredTile.extent(1, 250.0);
        }

        if (item == i) {
          return new StaggeredTile.extent(numColumns, 50.0);
        }
        i += 1;
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext ctx) {
    AppBar appBarWidget() {
      return new AppBar(
        title: const Text(consts.appName),
        actions: [
          new IconButton(
            icon: const Icon(Icons.view_column),
            tooltip: 'Set columns',
            onPressed: _onPressedChangeColumns(ctx),
          ),
          new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _clearPages,
          ),
        ],
      );
    }

    Widget bodyWidget() {
      return new FutureBuilder<int>(
        future: db.numColumns.value,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.hasData) {
            return new StaggeredGridView.countBuilder(
              crossAxisCount: snapshot.data,
              itemCount: _itemCount(),
              itemBuilder: _itemBuilder,
              staggeredTileBuilder: _staggeredTileBuilder(snapshot.data),
            );
          }

          if (snapshot.hasError) {
            _log.fine('error retrieving num columns: ${snapshot.error}');
          }

          return new Container();
        },
      );
    }

    Widget floatingActionButtonWidget() {
      return new Builder(builder: (ctx) { // Needed for Scaffold.of(ctx) to work
        return new FloatingActionButton(
          child: _isEditingTags ? const Icon(Icons.check) : const Icon(
              Icons.search),
          onPressed: _onPressedFloatingActionButton(ctx),
        );
      });
    }

    return new Scaffold(
      appBar: appBarWidget(),
      body: bodyWidget(),
      drawer: new _PostsPageDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}


class _PostsPageDrawer extends StatelessWidget {
  final Logger _log = new Logger('_PostsPageDrawer');

  @override
  Widget build(BuildContext ctx) {
    Widget headerWidget() {
      Widget userInfoWidget() {
        return new FutureBuilder<String>(
          future: db.username.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.hasData) {
              return new Text(snapshot.data);
            }

            if (snapshot.hasError) {
              _log.fine('error getting username from db: ${snapshot.error}');
            }

            return new RaisedButton(
              child: const Text('LOGIN'),
              onPressed: () => Navigator.popAndPushNamed(ctx, '/login'),
            );
          },
        );
      }

      return new DrawerHeader(child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const CircleAvatar(
                backgroundImage: const AssetImage('icons/paw.png'),
                radius: 48.0,
              ),
              userInfoWidget(),
            ],
      ));
    }

    return new Drawer(child: new ListView(children: [
      headerWidget(),
      new ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () => Navigator.popAndPushNamed(ctx, '/settings'),
      ),
      new ListTile(
        leading: const Icon(FontAwesomeIcons.patreon),
        title: const Text('Support ${consts.appName} on Patreon'),
        onTap: () => url.launch(consts.patreonCampaign),
      ),
      new AboutListTile(
        icon: const Icon(Icons.help),
        applicationName: consts.appName,
        applicationVersion: consts.appVersion,
        applicationLegalese: consts.about,
      ),
    ]));
  }
}

typedef Future<Tagset> TagEditor(Tagset tags);

class TagEntry extends StatelessWidget {
  static final Logger _log = new Logger('TagEntry');

  const TagEntry({
    @required this.controller,
    Key key,
  })
      : super(key: key);

  final TextEditingController controller;

  void _setTags(Tagset tags) {
    controller.text = tags.toString() + ' ';
    _setFocusToEnd(controller);
  }

  void _withTags(TagEditor editor) {
    Tagset tags = new Tagset.parse(controller.text);
    editor(tags).then(_setTags);
  }

  Function(String) _onSelectedFilterBy(BuildContext ctx) {
    return (selectedFilter) {
      String filterType = const {
        'Score': 'score',
        'Favorites': 'favcount',
        'Views': 'views',
      }[selectedFilter];
      assert(filterType != null);

      _withTags((tags) async {
        String valueString = tags[filterType];
        int value =
            valueString == null ? 0 : int.parse(valueString.substring(2));

        int min = await showDialog<int>(context: ctx, builder: (ctx) {
          return new RangeDialog(
            title: 'Posts with $filterType at least',
            value: value,
            max: 500,
          );
        });

        _log.info('$selectedFilter min value: $min');
        if (min == null) {
          return null;
        }

        if (min == 0) {
          tags.remove(filterType);
        } else {
          tags[filterType] = '>=$min';
        }
        return tags;
      });
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

    _withTags((tags) {
      if (orderType == 'new') {
        tags.remove('order');
      } else {
        tags['order'] = orderType;
      }

      return new Future.value(tags);
    });
  }

  Future<Null> _onPressedCopyLink() async {
    Clipboard.setData(new ClipboardData(
      text: (await db.tags.value).url(await db.host.value).toString(),
    ));
  }

  List<PopupMenuEntry<String>> Function(BuildContext) _popupMenuButtonItemBuilder(List<String> text) {
    return (ctx) {
      List<PopupMenuEntry<String>> items = new List(text.length);
      for (int i = 0; i < items.length; i++) {
        String t = text[i];
        items[i] = new PopupMenuItem(child: new Text(t), value: t);
      }
      return items;
    };
  }

  @override
  Widget build(BuildContext ctx) {
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

    Widget copyLinkWidget() {
      return new IconButton(
        icon: const Icon(Icons.content_copy),
        tooltip: 'Copy link',
        onPressed: _onPressedCopyLink,
      );
    }

    return new Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: new Column(mainAxisSize: MainAxisSize.min, children: [
        new TextField(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          inputFormatters: [new LowercaseTextInputFormatter()],
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                copyLinkWidget(),
                filterByWidget(),
                sortByWidget(),
              ]),
        ),
      ]),
    );
  }
}
