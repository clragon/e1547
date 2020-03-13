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

// TODO: this works but its kinda messy. clean up.
_PostsPageState postsPage;
Text appbarTitle = Text(appInfo.appName.toString());
bool loadTopVisible = false;
bool loadBottomVisible = false;
bool loadingPosts = true;
enum DrawerSelection {
  home,
  hot,
  favorites,
}
DrawerSelection _drawerSelection = DrawerSelection.home;

class PostsPage extends StatefulWidget {
  @override
  State createState() {
    postsPage = new _PostsPageState();
    return postsPage;
  }
}

class _PostsPageState extends State<PostsPage> {
  bool _isEditingTags = false;
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  Future<TextEditingController> _textEditingControllerFuture =
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

      if (!_isEditingTags) {
        _textEditingControllerFuture = db.tags.value.then((tags) {
          return new TextEditingController()..text = tags.toString() + ' ';
        });
      }
      TextEditingController tagController = await _textEditingControllerFuture;
      _setFocusToEnd(tagController);

      if (_isEditingTags) {
        db.tags.value = new Future.value(new Tagset.parse(tagController.text));
        if (_drawerSelection == DrawerSelection.home) {
          db.homeTags.value = db.tags.value;
        }

        _bottomSheetController?.close();
        clearPages();
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

  void clearPages() {
    setState(() {
      _pages.clear();
      loadingPosts = true;
    });
  }

  int _itemCount() {
    int i = 1;
    for (List<Post> p in _pages) {
      i += p.length;
    }
    return i;
  }

  // TODO: initial loading broken.
  Widget _itemBuilder(BuildContext ctx, int item) {
    Widget postPreview(List<Post> page, int postOnPage, int postOnAll) {
      return Container(
        height: 250,
        child: new PostPreview(page[postOnPage], onPressed: () {
          Navigator.of(ctx).push(new MaterialPageRoute<Null>(
            builder: (ctx) => new PostSwipe(
              _pages
                  .fold<Iterable<Post>>(
                      const Iterable.empty(), (a, b) => a.followedBy(b))
                  .toList(),
              startingIndex: postOnAll,
            ),
          ));
        }),
      );
    }

    // Special case for first page header.
    if (item == 0) {
      if (_pages.isEmpty) {
        _loadNextPage();
        loadingPosts = false;
      }
    }

    int posts = 0;

    for (int p = 0; p < _pages.length; p++) {
      List<Post> page = _pages[p];
      if (page.isEmpty) {
        return new Container();
      }
      posts += page.length;

      if (item >= posts - 6) {
        if (p + 1 >= _pages.length) {
          _loadNextPage();
        }
      }

      if (item < posts) {
        return postPreview(page, item - (posts - page.length), item);
      }
    }

    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      int i = 1;
      for (int p = 0; p < _pages.length; p++) {
        List<Post> page = _pages[p];
        i += page.length;

        // this ensures that there isn't a large
        // empty space on odd post numbers on a page.
        if (item == i - 1 - p) {
          return new StaggeredTile.fit(1);
        }

        if (item < i) {
          return const StaggeredTile.extent(1, 250.0);
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
        title: appbarTitle,
        actions: [
          new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: clearPages,
          ),
        ],
      );
    }

    Widget bodyWidget() {
      return new Stack(children: [
        new Visibility(
          visible: loadingPosts,
          child: new Center(
            child: Container(
              height: 28,
              width: 28,
              child: new CircularProgressIndicator(),
            ),
          ),
        ),
        new StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: _itemCount(),
          itemBuilder: _itemBuilder,
          staggeredTileBuilder: _staggeredTileBuilder(),
          physics: new BouncingScrollPhysics(),
        ),
      ]);
    }

    Widget floatingActionButtonWidget() {
      return new Builder(builder: (ctx) {
        // Needed for Scaffold.of(ctx) to work
        return new Visibility(
          visible: true,
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

void _setFocusToEnd(TextEditingController controller) {
  controller.selection = new TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
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
              return new Text(
                snapshot.data,
                style: new TextStyle(fontSize: 16.0),
              );
            }
            return new RaisedButton(
              child: const Text('LOGIN'),
              onPressed: () => Navigator.popAndPushNamed(ctx, '/login'),
            );
          },
        );
      }

      // this could use the avatar post of the user.
      // however, its not reachable by the API.
      // maybe send an email to the site owners.
      return new Container(
          height: 140,
          child: new DrawerHeader(
              child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundImage: const AssetImage('assets/icon/paw.png'),
                radius: 36.0,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: userInfoWidget(),
              ),
            ],
          )));
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
            postsPage.setState(() {
              db.tags.value = db.homeTags.value;
              if (postsPage._isEditingTags) {
                postsPage._bottomSheetController?.close();
              }
              postsPage.clearPages();
              appbarTitle = Text(appInfo.appName
                  .toString()); // Text((await db.host.value).split('.')[0]);
              Navigator.pop(ctx);
            });
          },
        ),
        new ListTile(
            selected: _drawerSelection == DrawerSelection.hot,
            leading: const Icon(Icons.show_chart),
            title: const Text('Hot'),
            onTap: () {
              _drawerSelection = DrawerSelection.hot;
              postsPage.setState(() {
                db.tags.value =
                    new Future.value(new Tagset.parse("order:rank"));
                if (postsPage._isEditingTags) {
                  postsPage._bottomSheetController?.close();
                }
                postsPage.clearPages();
                appbarTitle = Text('Hot');
                Navigator.pop(ctx);
              });
            }),
        new ListTile(
            selected: _drawerSelection == DrawerSelection.favorites,
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () async {
              _drawerSelection = DrawerSelection.favorites;
              String username = await db.username.value;
              postsPage.setState(() {
                if (username != null) {
                  db.tags.value =
                      new Future.value(new Tagset.parse('fav:' + username));
                } else {
                  db.tags.value = new Future.value(new Tagset.parse(''));
                  Scaffold.of(ctx).showSnackBar(new SnackBar(
                    duration: const Duration(seconds: 1),
                    content: new Text('You are not logged in.'),
                  ));
                }
                if (postsPage._isEditingTags) {
                  postsPage._bottomSheetController?.close();
                }
                postsPage.clearPages();
                appbarTitle = Text('Favorites');
                Navigator.pop(ctx);
              });
            }),
        Divider(),
        new ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => Navigator.popAndPushNamed(ctx, '/settings'),
        ),
        // TODO: get rid of this garbage and make own about screen.
        const AboutListTile(
          child: const Text('About'),
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
                division: 20,
                max: 200,
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
