import 'package:e1547/main.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
      _setFocusToEnd(_tagController);

      if (_isSearching) {
        query = _tagController.text;

        _bottomSheetController?.close();
        _clearPages();
      } else {
        _bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => new Container(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
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
    nextPage.addAll(await client.pools(query, p));
    _pages.add(nextPage);
    if (this.mounted) {
      setState(() {});
    }
  }

  void _clearPages() {
    setState(() {
      _pages.clear();
      _loading = true;
    });
  }

  int _itemCount() {
    int i = 0;
    if (_pages.isEmpty) {
      _loadNextPage();
      _loading = false;
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
      if (item >= pools - 6) {
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

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      int i = 0;
      for (int p = 0; p < _pages.length; p++) {
        List<Pool> page = _pages[p];
        i += page.length;
        if (item <= i) {
          // this might make everything uncomfortably laggy.
          return const StaggeredTile.fit(1);
        }
        i += 1;
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() {
      return new AppBar(
        title: Text('Pools'),
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
                  child: new Text('Loading pools'),
                ),
              ],
            ),
          ),
        ),
        new StaggeredGridView.countBuilder(
          crossAxisCount: 1,
          itemCount: _itemCount(),
          itemBuilder: _itemBuilder,
          staggeredTileBuilder: _staggeredTileBuilder(),
          physics: new BouncingScrollPhysics(),
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

void _setFocusToEnd(TextEditingController controller) {
  controller.selection = new TextSelection(
    baseOffset: controller.text.length,
    extentOffset: controller.text.length,
  );
}
