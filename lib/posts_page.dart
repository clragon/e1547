import 'dart:async' show Future;

import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGridView, StaggeredTile;
import 'package:meta/meta.dart' show required;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';

import 'client.dart' show client;
import 'input.dart' show LowercaseTextInputFormatter;
import 'main.dart' show NavigationDrawer;
import 'persistence.dart' show db;
import 'post.dart';
import 'range_dialog.dart' show RangeDialog;
import 'tag.dart' show Tagset;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        title: 'Home',
        tags: db.homeTags.value,
        tagChange: (tags) => {db.homeTags.value = new Future.value(tags)});
  }
}

class HotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        title: 'Hot', tags: Future.value(new Tagset.parse("order:rank")));
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        title: 'Favorites',
        tags: db.username.value.then((username) {
          return new Tagset.parse('fav:' + username);
        }));
  }
}

class SearchPage extends StatelessWidget {
  final Tagset tags;

  SearchPage(this.tags);

  @override
  Widget build(BuildContext context) {
    return new PostsPage(
      title: 'Search',
      tags: Future.value(tags),
      isHome: false,
    );
  }
}

class PoolPage extends StatelessWidget {
  final Pool pool;

  PoolPage(this.pool);

  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        title: pool.name.replaceAll('_', ' '),
        pool: pool,
        canSearch: false,
        isHome: false);
  }
}

class PostsPage extends StatefulWidget {
  final String title;
  final bool isHome;
  final Future<Tagset> tags;
  final Function(Tagset) tagChange;
  final Pool pool;
  final bool canSearch;

  const PostsPage(
      {this.title,
      this.tags,
      this.isHome = true,
      this.canSearch = true,
      this.pool,
      this.tagChange});

  static _PostsPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  State<StatefulWidget> createState() {
    return new _PostsPageState();
  }
}

class _PostsPageState extends State<PostsPage> {
  Tagset _tags;
  bool _isSearching = false;
  TextEditingController _tagController;
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  Function() _onPressedFloatingActionButton(BuildContext context) {
    return () async {
      void onCloseBottomSheet() {
        setState(() {
          _isSearching = false;
        });
      }

      if (!_isSearching) {
        _tagController = new TextEditingController()
          ..text = _tags.toString() + ' ';
      }
      _setFocusToEnd(_tagController);

      if (_isSearching) {
        _tags = await new Future.value(new Tagset.parse(_tagController.text));
        if (widget.tagChange != null) {
          widget.tagChange(_tags);
        }

        _bottomSheetController?.close();
        _clearPages();
      } else {
        _bottomSheetController = Scaffold.of(context).showBottomSheet(
          (context) => new TagEntry(controller: _tagController),
        );

        setState(() {
          _isSearching = true;
        });

        _bottomSheetController.closed.then((a) => onCloseBottomSheet());
      }
    };
  }

  final List<List<Post>> _pages = [];
  bool _loading = true;

  void _loadNextPage() async {
    int p = _pages.length;

    List<Post> nextPage = [];
    _pages.add(nextPage);

    if (_tags == null) {
      _tags = await widget.tags ?? new Tagset.parse('');
      _tagController = new TextEditingController()
        ..text = _tags.toString() + ' ';
    }

    if (widget.pool == null) {
      nextPage.addAll(await client.posts(_tags, p));
    } else {
      nextPage.addAll(await client.pool(widget.pool, p));
    }

    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clearPages() {
    setState(() {
      _loading = true;
      _pages.clear();
    });
  }

  int _itemCount() {
    int i = 0;
    if (_pages.isEmpty) {
      _loadNextPage();
    }
    for (List<Post> p in _pages) {
      i += p.length;
    }
    return i;
  }

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(List<Post> page, int pageIndex, int listIndex) {
      return Container(
        height: 250,
        child: new PostPreview(page[pageIndex], onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (context) => new PostSwipe(
              _pages
                  .fold<Iterable<Post>>(
                      const Iterable.empty(), (a, b) => a.followedBy(b))
                  .toList(),
              startingIndex: listIndex,
            ),
          ));
        }),
      );
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
        return preview(page, item - (posts - page.length), item);
      }
    }

    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      int i = 0;
      for (int p = 0; p < _pages.length; p++) {
        List<Post> page = _pages[p];
        i += page.length;

        // this ensures that there isn't a large
        // empty space on an even number of posts on a page.
        if (item == i - 1 - p) {
          return new StaggeredTile.fit(1);
        }

        // do not make all of them fit, since that causes lags.
        if (item < i) {
          return const StaggeredTile.extent(1, 250.0);
        }

        i += 1;
      }

      return null;
    };
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _pages.clear();
      _loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBarWidget() {
      return new AppBar(
        title: new Text(widget.title),
        leading: widget.isHome
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          widget.pool != null
              ? IconButton(
                  icon: Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () {
                    DateFormat dateFormat = DateFormat('dd.MM.yy hh:mm');
                    Color textColor = Colors.grey[600];
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('${widget.pool.name.replaceAll('_', ' ')} (#${widget.pool.id})'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            widget.pool.description != ''
                                ? PoolPreview.dTextField(
                                    context, widget.pool.description)
                                : Text(
                                    'no description',
                                    style:
                                        TextStyle(
                                            fontStyle: FontStyle.italic),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 8),
                              child: Divider(),
                            ),
                            // Text('Pool info', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('posts', style: TextStyle(color: textColor),),
                                Text(widget.pool.postIDs.length.toString(), style: TextStyle(color: textColor),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('status', style: TextStyle(color: textColor),),
                                widget.pool.active
                                    ? Text('active', style: TextStyle(color: textColor),)
                                    : Text('inactive', style: TextStyle(color: textColor),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('created', style: TextStyle(color: textColor),),
                                Text(dateFormat.format(
                                    DateTime.parse(widget.pool.creation)
                                        .toLocal()), style: TextStyle(color: textColor),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('updated', style: TextStyle(color: textColor),),
                                Text(dateFormat.format(
                                    DateTime.parse(widget.pool.updated)
                                        .toLocal()), style: TextStyle(color: textColor),),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          FlatButton(
                            child: Text('SHARE'),
                            onPressed: () async => Share.share(widget.pool
                                .url(await db.host.value)
                                .toString()),
                          ),
                          FlatButton(
                            child: Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : new Container(),
          new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _clearPages,
          ),
        ],
      );
    }

    Widget bodyWidget() {
      return new Stack(children: [
        new Visibility(
          visible: _loading,
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Container(
                  height: 28,
                  width: 28,
                  child: new CircularProgressIndicator(),
                ),
                new Padding(
                  padding: EdgeInsets.all(20),
                  child: new Text('Loading posts'),
                ),
              ],
            ),
          ),
        ),
        new OrientationBuilder(
            builder: (context, orientation) {
              return new StaggeredGridView.countBuilder(
                crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                itemCount: _itemCount(),
                itemBuilder: _itemBuilder,
                staggeredTileBuilder: _staggeredTileBuilder(),
                physics: new BouncingScrollPhysics(),
              );
            },
          ),
        new Visibility(
          visible: (!_loading && _pages.length == 1 && _pages[0].length == 0),
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Icon(
                  Icons.error_outline,
                  size: 32,
                ),
                new Padding(
                  padding: EdgeInsets.all(20),
                  child: new Text('No posts'),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    Widget floatingActionButtonWidget() {
      return new Builder(builder: (context) {
        return new Visibility(
          visible: widget.canSearch,
          child: new FloatingActionButton(
            heroTag: 'searchButton',
            child: _isSearching
                ? const Icon(Icons.check)
                : const Icon(Icons.search),
            onPressed: _onPressedFloatingActionButton(context),
          ),
        ).build(context);
      });
    }

    return new Scaffold(
      appBar: appBarWidget(),
      body: bodyWidget(),
      drawer: const NavigationDrawer(),
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

  Function(String) _onSelectedFilterBy(BuildContext context) {
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
            context: context,
            builder: (context) {
              return new RangeDialog(
                title: 'Posts with $filterType at least',
                value: value,
                division: 10,
                max: 100,
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
      'Rank': 'rank'
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
      text: Tagset.parse(controller.text).url(await db.host.value).toString(),
    ));
  }

  List<PopupMenuEntry<String>> Function(BuildContext)
      _popupMenuButtonItemBuilder(List<String> text) {
    return (context) {
      List<PopupMenuEntry<String>> items = new List(text.length);
      for (int i = 0; i < items.length; i++) {
        String t = text[i];
        items[i] = new PopupMenuItem(child: new Text(t), value: t);
      }
      return items;
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget filterByWidget() {
      return new PopupMenuButton<String>(
        icon: const Icon(Icons.filter_list),
        tooltip: 'Filter by',
        itemBuilder: _popupMenuButtonItemBuilder(
          ['Score', 'Favorites', 'Views'],
        ),
        onSelected: _onSelectedFilterBy(context),
      );
    }

    Widget sortByWidget() {
      return new PopupMenuButton<String>(
        icon: const Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: _popupMenuButtonItemBuilder(
          ['New', 'Score', 'Favorites', 'Views', 'Rank'],
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
          decoration: const InputDecoration(
            labelText: 'Tags',
          ),
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
