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
import 'package:logging/logging.dart' show Logger;
import 'package:meta/meta.dart' show required;

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

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    AppBar appBarWidget() {
      return new AppBar(
        title: const Text(consts.appName),
        actions: [
          new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
                // _pageController.jumpToPage(0);
                // setState(_pages.clear);
            },
          ),
        ],
      );
    }

    Widget floatingActionButtonWidget() {
      return new FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: (){},
      );
    }

    return new Scaffold(
      appBar: appBarWidget(),
      body: new _PostsPageView(),
      drawer: new _PostsPageDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}

class _PostsPageView extends StatefulWidget {
  @override
  State createState() => new _PostsPageViewState();
}

class _PostsPageViewState extends State<_PostsPageView> {
  final List<List<Post>> _pages = [];

  void _loadNextPage() async {
    int p = _pages.length;
    List<Post> nextPage = [];
    _pages.add(nextPage);

    nextPage.addAll(await client.posts(await db.tags.value, p + 1));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  // Item count is the total number of loaded posts, plus the page divider
  // between each page and the blank item at the very end.
  int _itemCount() {
    int i = 0;
    i += _pages.length;
    for (List<Post> p in _pages) {
      i += p.length;
    }
    return i;
  }

  Widget _itemBuilder(BuildContext ctx, int item) {
    Widget postPreview(List<Post> page, int post) {
      return new PostPreview(page[post], onPressed: () {
        Navigator.of(ctx).push(new MaterialPageRoute<Null>(
          builder: (ctx) => new PostSwipe(page, startingIndex: post),
        ));
      });
    }

    int i = 0;
    for (int p = 0; p < _pages.length; p++) {
      List<Post> page = _pages[p];
      i += page.length;
      if (item < i) {
        return postPreview(page, item - (i - page.length));
      } else if (item == i) {
        return new Text('page ${p + 1}');
      }
    }

    return null;
  }

  StaggeredTile _staggeredTileBuilder(int i) {
    return const StaggeredTile.extent(1, 250.0);
  }

  @override
  Widget build(BuildContext ctx) {
    return new StaggeredGridView.extentBuilder(
      itemCount: _itemCount(),
      maxCrossAxisExtent: 200.0,
      itemBuilder: _itemBuilder,
      staggeredTileBuilder: _staggeredTileBuilder,
    );
  }
}


  // final PageController _pageController = new PageController();

  // bool _isEditingTags = false;
  // PersistentBottomSheetController<Tagset> _bottomSheetController;

  // final Future<TextEditingController> _textEditingControllerFuture = db.tags.value.then((tags) {
  //   return new TextEditingController()..text = tags.toString() + ' ';
  // });

/*
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
        _tags = new Future.value(newTags);
        db.tags.value = _tags;

        _bottomSheetController?.close();
        setState(_pages.clear);
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
  */

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
          const AboutListTile(icon: const Icon(Icons.help)),
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
            title: filterType,
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
