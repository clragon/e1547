import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart' show db;
import 'package:e1547/tag.dart' show Tagset;
import 'package:e1547/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGridView, StaggeredTile;
import 'package:like_button/like_button.dart';
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
      future: db.credentials.value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return PostsPage(
              appBarBuilder: appBarWidget('Favorites'),
              provider: PostProvider(
                provider: (tags, page) {
                  return client.posts(tags, page);
                },
                search: 'fav:${snapshot.data.username}',
                denying: false,
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
  final bool canSelect;
  final AppBar Function(BuildContext) appBarBuilder;
  final PostProvider provider;

  PostsPage({
    this.canSearch = true,
    this.canSelect = true,
    @required this.provider,
    @required this.appBarBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  TextEditingController controller = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<Tagset> bottomSheetController;

  Set<Post> selections = Set();
  bool loading = true;
  bool staggered;
  int tileSize;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    // tileSize is not linked because updating it will break the grid
    db.staggered.addListener(() async {
      staggered = await db.staggered.value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db.tileSize.value.then((value) {
      tileSize = value;
      if (mounted) {
        setState(() {});
      }
    });
    db.staggered.value.then((value) {
      staggered = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(PostsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    selections.clear();
    loading = true;
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.dispose();
  }

  int notZero(int value) => value == 0 ? 1 : value;

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Post post, PostProvider provider) {
      void select() {
        if (widget.canSelect) {
          if (selections.contains(post)) {
            selections.remove(post);
          } else {
            selections.add(post);
          }
          setState(() {});
        }
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: PostPreview(
                post: post,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (context) => PostDetailGallery(
                      provider: provider,
                      initialPage: provider.posts.value.indexOf(post),
                    ),
                  ));
                }),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: selections.isNotEmpty ? select : null,
              onLongPress: select,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: selections.contains(post) ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Container(
                      color: Colors.black38,
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (item == widget.provider.posts.value.length - 1) {
      widget.provider.loadNextPage();
    }
    if (item < widget.provider.posts.value.length) {
      return preview(widget.provider.posts.value[item], widget.provider);
    }
    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      if (item < widget.provider.posts.value.length) {
        if (staggered) {
          Map sample = widget.provider.posts.value[item].image.value.sample;
          double heightRatio = (sample['height'] / sample['width']);
          double widthRatio = (sample['width'] / sample['height']);
          if (notZero((MediaQuery.of(context).size.width / tileSize).round()) ==
              1) {
            return StaggeredTile.count(1, heightRatio);
          } else {
            return StaggeredTile.count(
                notZero(widthRatio.round()), notZero(heightRatio.round()));
          }
        } else {
          return StaggeredTile.count(1, 1.2);
        }
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    widget.provider.pages.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (this.mounted) {
          setState(() {
            if (widget.provider.pages.value.length == 0 ||
                tileSize == null ||
                staggered == null) {
              loading = true;
            } else {
              loading = false;
            }
          });
        }
      });
    });

    Widget bodyWidget() {
      return pageLoader(
        onLoading: Text('Loading posts'),
        onEmpty: Text('No posts'),
        isLoading: loading,
        isEmpty: (!loading && widget.provider.posts.value.length == 0),
        child: tileSize != null && staggered != null
            ? SmartRefresher(
                controller: _refreshController,
                header: ClassicHeader(
                  refreshingText: 'Refreshing...',
                  completeText: 'Refreshed posts!',
                ),
                onRefresh: () async {
                  await widget.provider.loadNextPage(reset: true);
                  _refreshController.refreshCompleted();
                  selections.clear();
                },
                physics: BouncingScrollPhysics(),
                child: StaggeredGridView.countBuilder(
                  crossAxisCount: notZero(
                      (MediaQuery.of(context).size.width / tileSize).round()),
                  itemCount: widget.provider.posts.value.length,
                  itemBuilder: _itemBuilder,
                  staggeredTileBuilder: _staggeredTileBuilder(),
                  physics: BouncingScrollPhysics(),
                ))
            : Container(),
      );
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        if (widget.canSearch) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget child) {
              void submit() {
                widget.provider.search.value = controller.text;
                widget.provider.resetPages();
                bottomSheetController?.close();
              }

              return FloatingActionButton(
                heroTag: 'float',
                child: Icon(value ? Icons.check : Icons.search),
                onPressed: () async {
                  selections.clear();
                  if (isSearching.value) {
                    submit();
                  } else {
                    controller.text = widget.provider.search.value + ' ';
                    isSearching.value = true;
                    bottomSheetController =
                        Scaffold.of(context).showBottomSheet(
                      (context) => TagEntry(
                        controller: controller,
                        onSubmit: submit,
                      ),
                    );
                    isSearching.value = true;
                    bottomSheetController.closed.then((a) {
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

    Future<void> loadingSnackbar(BuildContext context,
        Future<bool> Function(Post post) process, Duration timeout) async {
      bool cancel = false;
      bool failure = false;
      List<Post> processing = List.from(selections);
      selections.clear();
      ValueNotifier<int> progress = ValueNotifier<int>(0);
      ScaffoldFeatureController controller =
          Scaffold.of(context).showSnackBar(SnackBar(
        content: ValueListenableBuilder(
            valueListenable: progress,
            builder: (BuildContext context, int value, Widget child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        value == processing.length
                            ? failure
                                ? 'Failure'
                                : 'Done'
                            : 'Post #${widget.provider.posts.value[value].id} ($value/${processing.length})',
                        overflow: TextOverflow.visible,
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TweenAnimationBuilder(
                            duration: timeout,
                            builder:
                                (BuildContext context, value, Widget child) {
                              return LinearProgressIndicator(
                                value: (1 / processing.length) * value,
                              );
                            },
                            tween:
                                Tween<double>(begin: 0, end: value.toDouble()),
                          ),
                        ),
                      ),
                      value == processing.length || failure
                          ? Container()
                          : InkWell(
                              child: Text('CANCEL'),
                              onTap: () {
                                cancel = true;
                              },
                            ),
                    ],
                  )
                ],
              );
            }),
        duration: Duration(days: 1),
      ));
      for (Post post in processing) {
        if (await process(post)) {
          await Future.delayed(timeout);
          progress.value++;
          setState(() {});
        } else {
          failure = true;
          progress.value = processing.length;
          break;
        }
        if (cancel) {
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
      controller.close();
      setState(() {});
      return;
    }

    Widget selectionAppBar() {
      return AppBar(
        title: Text('selected ${selections.length} posts'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => setState(selections.clear),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                selections.addAll(widget.provider.posts.value.toSet());
                setState(() {});
              }),
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () => loadingSnackbar(
                      context,
                      (post) => downloadDialog(context, post),
                      Duration(milliseconds: 100)))),
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: LikeButton(
                  isLiked: selections.every((post) => post.isFavorite.value),
                  circleColor: CircleColor(start: Colors.pink, end: Colors.red),
                  bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.pink,
                      dotSecondaryColor: Colors.red),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.favorite,
                      color: isLiked
                          ? Colors.pinkAccent
                          : Theme.of(context).iconTheme.color,
                    );
                  },
                  onTap: (isLiked) async {
                    if (isLiked) {
                      loadingSnackbar(context, (post) async {
                        if (post.isFavorite.value) {
                          return tryRemoveFav(context, post);
                        } else {
                          return true;
                        }
                      }, Duration(milliseconds: 800));
                      return false;
                    } else {
                      loadingSnackbar(context, (post) async {
                        if (!post.isFavorite.value) {
                          return tryAddFav(context, post);
                        } else {
                          return true;
                        }
                      }, Duration(milliseconds: 800));
                      return true;
                    }
                  },
                ),
              );
            },
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (selections.length > 0) {
          selections.clear();
          setState(() {});
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: selections.length == 0
            ? widget.appBarBuilder(context)
            : selectionAppBar(),
        body: bodyWidget(),
        drawer: NavigationDrawer(),
        floatingActionButton: floatingActionButtonWidget(),
      ),
    );
  }
}

class PostProvider extends DataProvider<Post> {
  ValueNotifier<List<String>> allowlist = ValueNotifier([]);
  ValueNotifier<List<Post>> denied = ValueNotifier([]);
  ValueNotifier<List<Post>> posts = ValueNotifier([]);
  ValueNotifier<bool> denying = ValueNotifier(true);

  PostProvider(
      {String search,
      Future<List<Post>> Function(String search, int page) provider,
      bool denying = true})
      : super(search: search, provider: provider ?? client.posts) {
    this.denying.value = denying;
    this.denying.addListener(refresh);
    pages.addListener(refresh);
    allowlist.addListener(refresh);
  }

  Future<void> resetPages() async {
    super.resetPages();
    dispose();
  }

  void refresh() async {
    List<String> denylist = [];
    if (denying.value) {
      denylist = (await db.denylist.value).where((line) {
        return !allowlist.value.contains(line);
      }).toList();
    }
    for (Post item in items) {
      item.isBlacklisted = await client.isBlacklisted(item, denylist);
    }
    posts.value = items.where((item) => !item.isBlacklisted).toList();
    denied.value = items.where((item) => item.isBlacklisted).toList();
  }

  void dispose() {
    for (Post post in items) {
      post.dispose();
    }
  }
}

class TagEntry extends StatelessWidget {
  final TextEditingController controller;
  final Function onSubmit;

  TagEntry({
    @required this.controller,
    @required this.onSubmit,
  });

  void _withTags(Future<Tagset> Function(Tagset tags) editor) async {
    controller.text = (await editor(Tagset.parse(controller.text))).toString();
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
                      title: Text('Minimum $filterType'),
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

          _withTags((tags) async {
            if (orderType == 'new') {
              tags.remove('order');
            } else {
              tags['order'] = orderType;
            }

            return tags;
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
        tagInputField(
          controller: controller,
          labelText: 'Tags',
          onSubmit: onSubmit,
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
