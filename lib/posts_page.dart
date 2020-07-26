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
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/persistence.dart' show db;
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart' show Tagset;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: appBarWidget('Home'),
      postProvider: PostProvider(
          provider: (tags, page) {
            db.homeTags.value = Future.value(tags);
            return client.posts(tags, page);
          },
          tags: db.homeTags.value),
    );
  }
}

class HotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: appBarWidget('Hot'),
      postProvider:
          PostProvider(tags: Future.value(Tagset.parse("order:rank"))),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
        appBarBuilder: appBarWidget('Favorites'),
        postProvider: PostProvider(
          provider: (tags, page) {
            return client.posts(tags, page, filter: false);
          },
          tags: db.username.value.then((username) {
            return Tagset.parse('fav:' + username);
          }),
        ));
  }
}

class PoolPage extends StatelessWidget {
  final Pool pool;

  PoolPage(this.pool);

  @override
  Widget build(BuildContext context) {
    return PostsPage(
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
      postProvider: PostProvider(provider: (tags, page) {
        return client.posts(Tagset.parse('pool:${pool.id} order:id'), page);
      }),
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
      postProvider: PostProvider(provider: (tags, page) {
        return client.follows(page);
      }),
    );
  }
}

class SearchPage extends StatelessWidget {
  final Tagset tags;

  SearchPage({this.tags});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Tagset> _tags = ValueNotifier(tags ?? Tagset.parse(''));
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: ValueListenableBuilder(
            valueListenable: _tags,
            builder: (context, value, child) {
              if (value.length == 1) {
                return Text(value.toString().replaceAll('_', ' '));
              } else {
                return Text('Search');
              }
            },
          ),
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
                    onPressed: () => wikiDialog(context, value.first.toString(),
                        actions: true),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        );
      },
      postProvider: PostProvider(
          provider: (tags, page) {
            _tags.value = tags;
            return client.posts(tags, page);
          },
          tags: Future.value(tags)),
    );
  }
}

AppBar Function(BuildContext context) appBarWidget(String title,
    {bool isHome = true}) {
  return (context) {
    return AppBar(
      title: Text(title),
      leading: isHome
          ? null
          : IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
    );
  };
}

class PostsPage extends StatefulWidget {
  final bool canSearch;
  final AppBar Function(BuildContext) appBarBuilder;
  final PostProvider postProvider;

  PostsPage({
    this.canSearch = true,
    this.postProvider,
    this.appBarBuilder,
  });

  static _PostsPageState of(BuildContext context) =>
      context.findAncestorStateOfType();

  @override
  State<StatefulWidget> createState() {
    return _PostsPageState();
  }
}

class _PostsPageState extends State<PostsPage> {
  TextEditingController _tagController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  bool _loading = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Post post, PostProvider provider) {
      return Container(
        height: 250,
        child: PostPreview(post, onPressed: () {
          Navigator.of(context).push(MaterialPageRoute<Null>(
            builder: (context) => PostSwipe(
              provider,
              startingIndex: provider.posts.indexOf(post),
            ),
          ));
        }),
      );
    }

    if (item == widget.postProvider.posts.length - 1) {
      widget.postProvider.loadNextPage();
    }
    if (item < widget.postProvider.posts.length) {
      return preview(widget.postProvider.posts[item], widget.postProvider);
    }
    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      if (item < widget.postProvider.posts.length) {
        return StaggeredTile.extent(1, 250.0);
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    widget.postProvider.pages.addListener(() {
      if (this.mounted) {
        setState(() {
          if (widget.postProvider.pages.value.length == 0) {
            _loading = true;
          } else {
            _loading = false;
          }
        });
      }
    });

    Widget bodyWidget() {
      return Stack(children: [
        Visibility(
          visible: _loading,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Loading posts'),
                ),
              ],
            ),
          ),
        ),
        SmartRefresher(
            controller: _refreshController,
            header: ClassicHeader(
              refreshingText: 'Refreshing...',
              completeText: 'Refreshed posts!',
            ),
            onRefresh: () async {
              await widget.postProvider.loadNextPage(reset: true);
              _refreshController.refreshCompleted();
            },
            physics: BouncingScrollPhysics(),
            // it is possible to replace this
            // with a normal GridView
            // however, I didn't like the aspect ratios.
            child: StaggeredGridView.countBuilder(
              crossAxisCount: (MediaQuery.of(context).size.width / 200).round(),
              itemCount: widget.postProvider.posts.length,
              itemBuilder: _itemBuilder,
              staggeredTileBuilder: _staggeredTileBuilder(),
              physics: BouncingScrollPhysics(),
            )),
        Visibility(
          visible: (!_loading && widget.postProvider.posts.length == 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 32,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No posts'),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        if (widget.canSearch) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget child) {
              return FloatingActionButton(
                heroTag: 'float',
                child: Icon(value ? Icons.check : Icons.search),
                onPressed: () async {
                  setFocusToEnd(_tagController);
                  if (isSearching.value) {
                    widget.postProvider.tags.value =
                        Future.value(Tagset.parse(_tagController.text));
                    _bottomSheetController?.close();
                    widget.postProvider.pages.value = [];
                  } else {
                    _tagController.text =
                        (await widget.postProvider.tags.value).toString() + ' ';
                    _bottomSheetController =
                        Scaffold.of(context).showBottomSheet(
                      (context) => TagEntry(
                        controller: _tagController,
                      ),
                    );
                    isSearching.value = true;
                    _bottomSheetController.closed.then((a) {
                      isSearching.value = false;
                    });
                  }
                },
              );
            },
          );
        } else {
          return Container();
        }
      }).build(context);
    }

    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: bodyWidget(),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}

class PostProvider {
  bool isLoading = false;
  ValueNotifier<Future<Tagset>> tags =
      ValueNotifier(Future.value(Tagset.parse('')));
  ValueNotifier<List<List<Post>>> pages = ValueNotifier([]);
  final Future<List<Post>> Function(Tagset tags, int page) provider;

  List<Post> get posts {
    return pages.value
        .fold<Iterable<Post>>(Iterable.empty(), (a, b) => a.followedBy(b))
        .toList();
  }

  PostProvider({tags, this.provider}) {
    this.tags.value = tags;
    this.tags.addListener(() {
      isLoading = false;
      loadNextPage(reset: true);
    });
    this.pages.addListener(() {
      if (pages.value.length == 0) {
        loadNextPage();
      }
    });
    loadNextPage();
  }

  Future<void> loadNextPage({bool reset = false}) async {
    if (!isLoading) {
      isLoading = true;
      if (await tags.value == null) {
        tags.value = Future.value(new Tagset.parse(''));
      }
      int page = reset ? 0 : pages.value.length;
      List<Post> nextPage = [];
      if (provider != null) {
        nextPage.addAll(await provider((await tags.value), page));
      } else {
        nextPage.addAll(await client.posts((await tags.value), page));
      }
      if (nextPage.length != 0 || pages.value.length == 0) {
        if (reset) {
          pages.value = [nextPage];
        } else {
          pages.value = List.from(pages.value..add(nextPage));
        }
      }
      isLoading = false;
    }
  }
}

class TagEntry extends StatelessWidget {
  final TextEditingController controller;

  TagEntry({
    @required this.controller,
  });

  void _withTags(Future<Tagset> Function(Tagset tags) editor) async {
    Tagset tags = await editor(Tagset.parse(controller.text));
    controller.text = tags.toString() + ' ';
    setFocusToEnd(controller);
  }

  List<PopupMenuEntry<String>> Function(BuildContext)
      _popupMenuButtonItemBuilder(List<String> text) {
    return (context) {
      List<PopupMenuEntry<String>> items = List(text.length);
      for (int i = 0; i < items.length; i++) {
        String t = text[i];
        items[i] = PopupMenuItem(child: Text(t), value: t);
      }
      return items;
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget filterByWidget() {
      return PopupMenuButton<String>(
          icon: Icon(Icons.filter_list),
          tooltip: 'Filter by',
          itemBuilder: _popupMenuButtonItemBuilder(
            ['Score', 'Favorites'],
          ),
          onSelected: (selectedFilter) {
            String filterType = {
              'Score': 'score',
              'Favorites': 'favcount',
            }[selectedFilter];

            _withTags((tags) async {
              String valueString = tags[filterType];
              int value =
                  valueString == null ? 0 : int.parse(valueString.substring(2));

              int min = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    return RangeDialog(
                      title: 'Minimum $filterType',
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
          });
    }

    Widget sortByWidget() {
      return PopupMenuButton<String>(
        icon: Icon(Icons.sort),
        tooltip: 'Sort by',
        itemBuilder: _popupMenuButtonItemBuilder(
          ['New', 'Score', 'Favorites', 'Rank'],
        ),
        onSelected: (String selectedSort) {
          String orderType = {
            'New': 'new',
            'Score': 'score',
            'Favorites': 'favcount',
            'Rank': 'rank'
          }[selectedSort];
          assert(orderType != null);

          _withTags((tags) {
            if (orderType == 'new') {
              tags.remove('order');
            } else {
              tags['order'] = orderType;
            }

            return Future.value(tags);
          });
        },
      );
    }

    Widget copyLinkWidget() {
      return IconButton(
        icon: Icon(Icons.content_copy),
        tooltip: 'Copy link',
        onPressed: () async {
          Clipboard.setData(ClipboardData(
            text: Tagset.parse(controller.text)
                .url(await db.host.value)
                .toString(),
          ));
          Scaffold.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Copied URL to clipboard'),
            behavior: SnackBarBehavior.floating,
          ));
        },
      );
    }

    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TypeAheadField(
          direction: AxisDirection.up,
          hideOnLoading: true,
          hideOnEmpty: true,
          hideOnError: true,
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            autofocus: true,
            maxLines: 1,
            inputFormatters: [LowercaseTextInputFormatter()],
            decoration: InputDecoration(
                labelText: 'Tags', border: UnderlineInputBorder()),
          ),
          onSuggestionSelected: (suggestion) {
            List<String> tags = controller.text.split(' ');
            List<String> before = [];
            for (String tag in tags) {
              before.add(tag);
              if (before.join(' ').length >=
                  controller.selection.extent.offset) {
                tags[tags.indexOf(tag)] = suggestion;
                break;
              }
            }
            controller.text = tags.join(' ') + ' ';
          },
          itemBuilder: (BuildContext context, itemData) {
            return ListTile(
              title: Text(itemData),
            );
          },
          suggestionsCallback: (String pattern) async {
            List<String> tags = controller.text.split(' ');
            List<String> before = [];
            int selection = 0;
            for (String tag in tags) {
              before.add(tag);
              if (before.join(' ').length >=
                  controller.selection.extent.offset) {
                selection = tags.indexOf(tag);
                break;
              }
            }
            if (tags[selection].trim().isNotEmpty) {
              return (await client.tags(tags[selection]))
                  .map((t) => t['name'])
                  .toList();
            } else {
              return [];
            }
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            copyLinkWidget(),
            filterByWidget(),
            sortByWidget(),
          ]),
        ),
      ]),
    );
  }
}
