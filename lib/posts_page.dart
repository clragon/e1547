import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart' show db;
import 'package:e1547/tag.dart' show Tagset, sortTags;
import 'package:e1547/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGridView, StaggeredTile;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:meta/meta.dart' show required;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar Function(BuildContext) appbar = appBarWidget('Home');
    return FutureBuilder(
      future: db.homeTags.value,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          PostProvider provider = PostProvider(
            search: snapshot.data,
          );
          provider.search.addListener(
              () => db.homeTags.value = Future.value(provider.search.value));
          return PostsPage(appBarBuilder: appbar, provider: provider);
        } else {
          return Scaffold(
            appBar: appbar(context),
            body: Center(
              child: Container(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class HotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostsPage(
      appBarBuilder: appBarWidget('Hot'),
      provider: PostProvider(search: "order:rank"),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.username.value,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PostsPage(
              appBarBuilder: appBarWidget('Favorites'),
              provider: PostProvider(
                provider: (tags, page) {
                  return client.posts(tags, page, filter: false);
                },
                search: 'fav:${snapshot.data}',
              ));
        } else {
          return Scaffold(
            appBar: appBarWidget('Favorites')(context),
            body: Center(
              child: Container(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class PoolPage extends StatelessWidget {
  final Pool pool;

  PoolPage({@required this.pool});

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
      provider: PostProvider(
          provider: (tags, page) =>
              client.posts('pool:${pool.id} order:id', page)),
      canSearch: false,
    );
  }
}

class FollowsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: db.follows,
      builder: (context, value, child) {
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
          provider:
              PostProvider(provider: (tags, page) => client.follows(page)),
        );
      },
    );
  }
}

class SearchPage extends StatelessWidget {
  final String tags;
  SearchPage({this.tags});

  @override
  Widget build(BuildContext context) {
    PostProvider provider = PostProvider(search: tags);
    return PostsPage(
      appBarBuilder: (context) {
        return AppBar(
          title: ValueListenableBuilder(
            valueListenable: provider.search,
            builder: (context, value, child) {
              if (Tagset.parse(value).length == 1) {
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
              valueListenable: provider.search,
              builder: (context, value, child) {
                if (Tagset.parse(value).length == 1) {
                  return IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () => wikiDialog(context, value, actions: true),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        );
      },
      provider: provider,
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
  final PostProvider provider;

  PostsPage({
    this.canSearch = true,
    @required this.provider,
    @required this.appBarBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  TextEditingController _tagController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<Tagset> _bottomSheetController;

  bool _loading = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void didUpdateWidget(PostsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loading = true;
  }

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Post post, PostProvider provider) {
      return Container(
        height: 250,
        child: PostPreview(
            post: post,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<Null>(
                builder: (context) => PostSwipe(
                  provider: provider,
                  startingIndex: provider.items.indexOf(post),
                ),
              ));
            }),
      );
    }

    if (item == widget.provider.items.length - 1) {
      widget.provider.loadNextPage();
    }
    if (item < widget.provider.items.length) {
      return preview(widget.provider.items[item], widget.provider);
    }
    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      if (item < widget.provider.items.length) {
        return StaggeredTile.extent(1, 250.0);
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    widget.provider.pages.addListener(() {
      if (this.mounted) {
        setState(() {
          if (widget.provider.pages.value.length == 0) {
            _loading = true;
          } else {
            _loading = false;
          }
        });
      }
    });

    Widget bodyWidget() {
      return pageLoader(
        onLoading: Text('Loading posts'),
        onEmpty: Text('No posts'),
        isLoading: _loading,
        isEmpty: (!_loading && widget.provider.items.length == 0),
        child: SmartRefresher(
            controller: _refreshController,
            header: ClassicHeader(
              refreshingText: 'Refreshing...',
              completeText: 'Refreshed posts!',
            ),
            onRefresh: () async {
              await widget.provider.loadNextPage(reset: true);
              _refreshController.refreshCompleted();
            },
            physics: BouncingScrollPhysics(),
            // it is possible to replace this
            // with a normal GridView
            // however, I didn't like the aspect ratios.
            child: StaggeredGridView.countBuilder(
              crossAxisCount: (MediaQuery.of(context).size.width / 200).round(),
              itemCount: widget.provider.items.length,
              itemBuilder: _itemBuilder,
              staggeredTileBuilder: _staggeredTileBuilder(),
              physics: BouncingScrollPhysics(),
            )),
      );
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        if (widget.canSearch) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget child) {
              void submit() {
                widget.provider.search.value = sortTags(_tagController.text);
                _bottomSheetController?.close();
                widget.provider.resetPages();
              }

              return FloatingActionButton(
                heroTag: 'float',
                child: Icon(value ? Icons.check : Icons.search),
                onPressed: () async {
                  setFocusToEnd(_tagController);
                  if (isSearching.value) {
                    submit();
                  } else {
                    _tagController.text = widget.provider.search.value + ' ';
                    _bottomSheetController =
                        Scaffold.of(context).showBottomSheet(
                      (context) => TagEntry(
                        controller: _tagController,
                        onSubmit: submit,
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

class PostProvider extends DataProvider<Post> {
  List<Post> get posts => super.items;

  PostProvider(
      {String search,
      Future<List<Post>> Function(String search, int page) provider})
      : super(search: search, provider: provider ?? client.posts);
}

class TagEntry extends StatelessWidget {
  final TextEditingController controller;
  final Function onSubmit;

  TagEntry({
    @required this.controller,
    this.onSubmit,
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
          keepSuggestionsOnSuggestionSelected: true,
          textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              autofocus: true,
              maxLines: 1,
              inputFormatters: [LowercaseTextInputFormatter()],
              decoration: InputDecoration(
                  labelText: 'Tags', border: UnderlineInputBorder()),
              onSubmitted: (_) {
                if (onSubmit != null) {
                  onSubmit();
                }
              }),
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
            controller.text = sortTags(tags.join(' ')) + ' ';
            setFocusToEnd(controller);
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
