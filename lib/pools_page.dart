import 'package:e1547/main.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'client.dart';
import 'input.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage();

  @override
  State<StatefulWidget> createState() {
    return new _PoolsPageState();
  }
}

class _PoolsPageState extends State<PoolsPage> {
  String query = '';
  bool _isSearching = false;
  TextEditingController _tagController;
  PersistentBottomSheetController<String> _bottomSheetController;

  Function() _onPressedFloatingActionButton(BuildContext context) {
    return () async {
      void onCloseBottomSheet() {
        setState(() {
          _isSearching = false;
        });
      }

      if (!_isSearching) {
        _tagController = new TextEditingController()..text = query + ' ';
      }
      setFocusToEnd(_tagController);

      if (_isSearching) {
        query = _tagController.text;

        _bottomSheetController?.close();
        _clearPages();
      } else {
        _bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => new Container(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, bottom: 10),
                  child: new Column(mainAxisSize: MainAxisSize.min, children: [
                    new TextField(
                      controller: _tagController,
                      autofocus: true,
                      maxLines: 1,
                      inputFormatters: [new LowercaseTextInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                  ]),
                ));

        setState(() {
          _isSearching = true;
        });

        _bottomSheetController.closed.then((a) => onCloseBottomSheet());
      }
    };
  }

  final List<List<Pool>> _pages = [];
  bool _loading = true;

  void _loadNextPage() async {
    int p = _pages.length;

    List<Pool> nextPage = [];
    _pages.add(nextPage);

    nextPage.addAll(await client.pools(query, p));
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
    for (List<Pool> p in _pages) {
      i += p.length;
    }
    return i;
  }

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(List<Pool> page, int pageIndex, int listIndex) {
      return new PoolPreview(page[pageIndex], onPressed: () {
        Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (context) => new PoolPage(page[pageIndex]),
        ));
      });
    }

    int pools = 0;

    for (int p = 0; p < _pages.length; p++) {
      List<Pool> page = _pages[p];
      if (page.isEmpty) {
        return new Container();
      }
      pools += page.length;
      if (item == pools - 1) {
        if (p + 1 >= _pages.length) {
          _loadNextPage();
        }
      }

      if (item < pools) {
        return preview(page, item - (pools - page.length), item);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() {
      return new AppBar(
        title: Text('Pools'),
      );
    }

    Widget bodyWidget() {
      return new Stack(children: [
        Visibility(
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
                  child: new Text('Loading pools'),
                ),
              ],
            ),
          ),
        ),
        SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            completeText: 'refreshing...',
          ),
          onRefresh: _clearPages,
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            itemCount: _itemCount(),
            itemBuilder: _itemBuilder,
            physics: new BouncingScrollPhysics(),
          ),
        ),
        Visibility(
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
                  child: new Text('No pools'),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    Widget floatingActionButtonWidget() {
      return new Builder(builder: (context) {
        return new FloatingActionButton(
          child:
              _isSearching ? const Icon(Icons.check) : const Icon(Icons.search),
          onPressed: _onPressedFloatingActionButton(context),
        ).build(context);
      });
    }

    return new Scaffold(
      appBar: appBar(),
      body: bodyWidget(),
      drawer: const NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
