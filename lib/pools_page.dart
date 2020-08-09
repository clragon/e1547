import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PoolsPage extends StatefulWidget {
  PoolsPage();

  @override
  State<StatefulWidget> createState() {
    return _PoolsPageState();
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
        _tagController = TextEditingController()..text = query + ' ';
      }
      setFocusToEnd(_tagController);

      if (_isSearching) {
        query = _tagController.text;

        _bottomSheetController?.close();
        _clearPages();
      } else {
        _bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                      controller: _tagController,
                      autofocus: true,
                      maxLines: 1,
                      inputFormatters: [LowercaseTextInputFormatter()],
                      decoration: InputDecoration(
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
      return PoolPreview(page[pageIndex], onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (context) => PoolPage(pool: page[pageIndex]),
        ));
      });
    }

    int pools = 0;

    for (int p = 0; p < _pages.length; p++) {
      List<Pool> page = _pages[p];
      if (page.isEmpty) {
        return Container();
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
      return AppBar(
        title: Text('Pools'),
      );
    }

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
                  child: Text('Loading pools'),
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
            physics: BouncingScrollPhysics(),
          ),
        ),
        Visibility(
          visible: (!_loading && _pages.length == 1 && _pages[0].length == 0),
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
                  child: Text('No pools'),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        return FloatingActionButton(
          child: _isSearching ? Icon(Icons.check) : Icon(Icons.search),
          onPressed: _onPressedFloatingActionButton(context),
        ).build(context);
      });
    }

    return Scaffold(
      appBar: appBar(),
      body: bodyWidget(),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
