import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGridView, StaggeredTile;
import 'package:meta/meta.dart' show required;

import 'client.dart' show client;
import 'appinfo.dart' as appInfo;
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

_PostsPageState _postsPage;
bool _fabVisible = true;

enum DrawerSelection { home, hot, favorites, }
DrawerSelection _drawerSelection = DrawerSelection.home;

class PostsPage extends StatefulWidget {
  @override
  State createState() {
    _postsPage = new _PostsPageState();
    return _postsPage;
  }
}

class _PostsPageState extends State<PostsPage> {
  bool _isEditingTags = false;
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  final Future<TextEditingController> _textEditingControllerFuture =
      db.tags.value.then((tags) {
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
        db.tags.value = new Future.value(newTags);
        db.homeTags.value = new Future.value(newTags);

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
            _pages
                .fold<Iterable<Post>>(
                    const Iterable.empty(), (a, b) => a.followedBy(b))
                .toList(),
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

    // Special case for first page header.
    if (item == 0) {
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
        return postPreview(page, item - (i - page.length), item - (p + 1));
      }

      // Header for next page
      if (item == i) {
        int nextPage = p + 1;
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
        title: const Text(appInfo.appName),
        actions: [
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
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError &&
              snapshot.hasData) {
            return new StaggeredGridView.countBuilder(
              crossAxisCount: snapshot.data,
              itemCount: _itemCount(),
              itemBuilder: _itemBuilder,
              staggeredTileBuilder: _staggeredTileBuilder(snapshot.data),
            );
          }

          if (snapshot.hasError) {}

          return new Container();
        },
      );
    }

    Widget floatingActionButtonWidget() {
      return new Builder(builder: (ctx) {
        // Needed for Scaffold.of(ctx) to work
        return new Visibility(
          visible: _fabVisible,
          child: new FloatingActionButton(
            child: _isEditingTags
                ? const Icon(Icons.check)
                : const Icon(Icons.search),
            onPressed: _onPressedFloatingActionButton(ctx),
          ),
        ).build(ctx);
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
  @override
  Widget build(BuildContext ctx) {
    Widget headerWidget() {
      Widget userInfoWidget() {
        return new FutureBuilder<String>(
          future: db.username.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                snapshot.hasData) {
              return new Text(snapshot.data);
            }

            if (snapshot.hasError) {}

            return new RaisedButton(
              child: const Text('LOGIN'),
              onPressed: () => Navigator.popAndPushNamed(ctx, '/login'),
            );
          },
        );
      }

      return new DrawerHeader(
          child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const CircleAvatar(
            backgroundImage: const AssetImage('assets/icon/paw.png'),
            radius: 48.0,
          ),
          userInfoWidget(),
        ],
      ));
    }

    Function() _onPressedChangeColumns(BuildContext ctx) {
      return () async {
        int numColumns = await db.numColumns.value ?? 3;
        int newNumColumns = await showDialog<int>(
            context: ctx,
            builder: (ctx) {
              return new RangeDialog(
                title: 'Number of columns',
                value: numColumns,
                max: 10,
                min: 1,
              );
            });

        if (newNumColumns != null && newNumColumns > 0) {
          _postsPage.setState(() {
            db.numColumns.value = new Future.value(newNumColumns);
          });
          Navigator.pop(ctx);
        }
      };
    }

    return new Drawer(
      child: new ListView(children: [
        headerWidget(),
        new ListTile(
          selected: _drawerSelection == DrawerSelection.home,
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            _drawerSelection = DrawerSelection.home;
            _postsPage.setState(() {
              db.tags.value = db.homeTags.value;
              _postsPage._clearPages();
              // _fabVisible = true;
              Navigator.pop(ctx);
            });
          },
        ),
        new ListTile(
            selected: _drawerSelection == DrawerSelection.hot,
            leading: const Icon(Icons.show_chart),
            title: const Text('Favorites'),
            onTap: () {
              _drawerSelection = DrawerSelection.hot;
              _postsPage.setState(() {
                db.tags.value = new Future.value(new Tagset.parse("order:rank"));
                _postsPage._clearPages();
                // _fabVisible = false;
                Navigator.pop(ctx);
              });
            }),
        new ListTile(
          selected: _drawerSelection == DrawerSelection.favorites,
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              _drawerSelection = DrawerSelection.favorites;
              _postsPage.setState(() async {
                db.tags.value = new Future.value(new Tagset.parse("fav:" + await db.username.value));
                print(db.tags.value);
                _postsPage._clearPages();
                // _fabVisible = false;
                Navigator.pop(ctx);
              });
            }),
        Divider(),
        new ListTile(
          leading: const Icon(Icons.view_column),
          title: const Text('Columns'),
          onTap: _onPressedChangeColumns(ctx),
        ),
        Divider(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(ctx, '/settings'),
        ),
        const AboutListTile(
          icon: const Icon(Icons.help),
          applicationName: appInfo.appName,
          applicationVersion: appInfo.appVersion,
          applicationLegalese: appInfo.about,
        ),
      ]),
    );
  }
}

typedef Future<Tagset> TagEditor(Tagset tags);

class TagEntry extends StatelessWidget {
  const TagEntry({
    @required this.controller,
    Key key,
  }) : super(key: key);

  final TextEditingController controller;

  void _setTags(Tagset tags) {
    controller.text = tags.toString() + ' ';
    _setFocusToEnd(controller);
  }

  void _withTags(TagEditor editor) async {
    Tagset tags = await editor(new Tagset.parse(controller.text));
    _setTags(tags);
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

        int min = await showDialog<int>(
            context: ctx,
            builder: (ctx) {
              return new RangeDialog(
                title: 'Posts with $filterType at least',
                value: value,
                max: 500,
              );
            });

        if (min == null) {
          return tags;
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
      'Hot': 'rank'
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

  List<PopupMenuEntry<String>> Function(BuildContext)
      _popupMenuButtonItemBuilder(List<String> text) {
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
          ['New', 'Score', 'Favorites', 'Views', 'Hot'],
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
