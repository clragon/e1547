import 'dart:async' show Future;

import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGridView, StaggeredTile;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:meta/meta.dart' show required;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';

import 'blacklist_page.dart';
import 'client.dart' show client;
import 'input.dart' show LowercaseTextInputFormatter, setFocusToEnd;
import 'interface.dart';
import 'main.dart' show NavigationDrawer;
import 'persistence.dart' show db;
import 'post.dart';
import 'range_dialog.dart' show RangeDialog;
import 'tag.dart' show Tagset;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        appBarBuilder: appBarWidget('Home'),
        tags: db.homeTags.value,
        tagChange: (tags) => {db.homeTags.value = new Future.value(tags)});
  }
}

class HotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        appBarBuilder: appBarWidget('Hot'),
        tags: Future.value(new Tagset.parse("order:rank")));
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PostsPage(
        appBarBuilder: appBarWidget('Favorites'),
        tags: db.username.value.then((username) {
          return new Tagset.parse('fav:' + username);
        }));
  }
}

class PoolPage extends StatelessWidget {
  final Pool pool;

  PoolPage(this.pool);

  @override
  Widget build(BuildContext context) {
    return new PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text(pool.name.replaceAll('_', ' ')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              tooltip: 'Info',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => poolInfo(context, pool),
                );
              },
            )
          ],
        );
      },
      postProvider: (tags, page) async {
        return await client.pool(pool, page);
      },
      canSearch: false,
    );
  }
}

class FollowsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text('Following'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.turned_in),
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/following'),
            )
          ],
        );
      },
      canSearch: false,
      postProvider: (tags, page) async {
        return await client.follows(page);
      },
    );
  }
}

class SearchPage extends StatelessWidget {
  final Tagset tags;
  SearchPage(this.tags);

  @override
  Widget build(BuildContext context) {
    ValueNotifier _tags = ValueNotifier(tags);
    return new PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: Text('Search'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            ValueListenableBuilder(
              valueListenable: _tags,
              builder: (context, value, child) {
                if (value.length == 1) {
                  return IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        child: wikiDialog(context, value.first.toString(),
                            actions: true),
                      );
                    },
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        );
      },
      postProvider: (tags, page) async {
        _tags.value = tags;
        return await client.posts(tags, page);
      },
      tags: Future.value(tags),
    );
  }
}

AppBar Function(BuildContext context) appBarWidget(String title,
    {bool isHome = true}) {
  return (context) {
    return new AppBar(
      title: new Text(title),
      leading: isHome
          ? null
          : IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
    );
  };
}


class _FollowButton extends StatefulWidget {
  final Pool pool;

  const _FollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return _FollowButtonState();
  }
}

class _FollowButtonState extends State<_FollowButton> {
  bool following = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> follows = snapshot.data;
          String tag = 'pool:${widget.pool.id}';
          follows.forEach((b) {
            if (b == tag) {
              following = true;
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (following) {
                    follows.removeAt(follows.indexOf(tag));
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = false;
                    });
                  } else {
                    follows.add(tag);
                    db.follows.value = Future.value(follows);
                    setState(() {
                      following = true;
                    });
                  }
                },
                icon: following
                    ? Icon(Icons.turned_in)
                    : Icon(Icons.turned_in_not),
                tooltip: following ? 'follow tag' : 'unfollow tag',
              ),
            ],
          );
        } else {
          return Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.turned_in_not),
                onPressed: () {},
              ),
            ],
          );
        }
      },
      future: db.follows.value,
    );
  }
}

Widget poolInfo(BuildContext context, Pool pool) {
  DateFormat dateFormat = DateFormat('dd.MM.yy hh:mm');
  Color textColor = Colors.grey[600];
  return AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
            softWrap: true,
          ),
        ),
        _FollowButton(pool),
      ],
    ),
    content: ConstrainedBox(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              pool.description != ''
                  ? dTextField(context, pool.description)
                  : Text(
                      'no description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'posts',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    pool.postIDs.length.toString(),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'status',
                    style: TextStyle(color: textColor),
                  ),
                  pool.active
                      ? Text(
                          'active',
                          style: TextStyle(color: textColor),
                        )
                      : Text(
                          'inactive',
                          style: TextStyle(color: textColor),
                        ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'created',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    dateFormat.format(DateTime.parse(pool.creation).toLocal()),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'updated',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    dateFormat.format(DateTime.parse(pool.updated).toLocal()),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ],
          ),
          physics: BouncingScrollPhysics(),
        ),
        constraints: new BoxConstraints(
          maxHeight: 400.0,
        )),
    actions: [
      FlatButton(
        child: Text('SHARE'),
        onPressed: () async =>
            Share.share(pool.url(await db.host.value).toString()),
      ),
      FlatButton(
        child: Text('OK'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}

class PostsPage extends StatefulWidget {
  final bool canSearch;
  final Future<Tagset> tags;
  final void Function(Tagset) tagChange;
  final AppBar Function(BuildContext) appBarBuilder;
  final Future<List<Post>> Function(Tagset tags, int page) postProvider;

  const PostsPage({
    this.canSearch = true,
    this.tags,
    this.tagChange,
    this.postProvider,
    this.appBarBuilder,
  });

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
      setFocusToEnd(_tagController);

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
    int page = _pages.length;

    List<Post> nextPage = [];
    _pages.add(nextPage);

    if (_tags == null) {
      _tags = await widget.tags ?? new Tagset.parse('');
      _tagController = new TextEditingController()
        ..text = _tags.toString() + ' ';
    }

    if (widget.postProvider != null) {
      nextPage.addAll(await widget.postProvider(_tags, page));
    } else {
      nextPage.addAll(await client.posts(_tags, page));
    }

    if (this.mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _clearPages() {
    setState(() {
      _loading = true;
      _pages.clear();
      _refreshController.refreshCompleted();
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

      if (item == posts - 1) {
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
            return SmartRefresher(
                controller: _refreshController,
                header: ClassicHeader(
                  completeText: 'refreshing...',
                ),
                onRefresh: _clearPages,
                physics: BouncingScrollPhysics(),
                child: new StaggeredGridView.countBuilder(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  itemCount: _itemCount(),
                  itemBuilder: _itemBuilder,
                  staggeredTileBuilder: _staggeredTileBuilder(),
                  physics: BouncingScrollPhysics(),
                ));
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
      appBar: widget.appBarBuilder(context),
      body: bodyWidget(),
      drawer: const NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
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
    setFocusToEnd(controller);
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
        TypeAheadField(
          direction: AxisDirection.up,
          hideOnLoading: true,
          hideOnEmpty: true,
          hideOnError: true,
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            autofocus: true,
            maxLines: 1,
            inputFormatters: [new LowercaseTextInputFormatter()],
            decoration: InputDecoration(
                labelText: 'Tags', border: UnderlineInputBorder()),
          ),
          onSuggestionSelected: (suggestion) {
            List<String> tags = controller.text.toString().split(' ');
            if (suggestion.contains(noDash(tags[tags.length - 1]))) {
              tags[tags.length - 1] = tags[tags.length - 1][0] == '-'
                  ? '-' + suggestion
                  : suggestion;
            } else {
              tags.add(suggestion);
            }
            String query = '';
            for (String tag in tags) {
              query = query + tag + ' ';
            }
            controller.text = query;
          },
          itemBuilder: (BuildContext context, itemData) {
            return new ListTile(
              title: Text(itemData),
            );
          },
          suggestionsCallback: (String pattern) {
            List<String> tags = pattern.split(' ');
            return client.tags(noDash(tags[tags.length - 1]), 0);
          },
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
