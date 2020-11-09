import 'package:e1547/interface/page_loader.dart';
import 'package:e1547/main/drawer.dart';
import 'package:e1547/pools/pool.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/util/provider.dart';
import 'package:e1547/util/text_helper.dart';
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
  bool _loading = true;
  PoolProvider provider = PoolProvider();
  TextEditingController _tagController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<String> _bottomSheetController;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Pool pool, PoolProvider provider) {
      return PoolPreview(pool, onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (context) => PoolPage(pool: pool),
        ));
      });
    }

    if (item == provider.pools.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.pools.length) {
      return preview(provider.pools[item], provider);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    provider.pages.addListener(() {
      if (this.mounted) {
        setState(() {
          if (provider.pages.value.length == 0) {
            _loading = true;
          } else {
            _loading = false;
          }
        });
      }
    });

    Widget bodyWidget() {
      return PageLoader(
        onLoading: Text('Loading pools'),
        onEmpty: Text('No pools'),
        isLoading: _loading,
        isEmpty: (!_loading &&
            provider.pages.value.length == 1 &&
            provider.pages.value[0].length == 0),
        child: SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            refreshingText: 'Refreshing...',
            completeText: 'Refreshed pools!',
          ),
          onRefresh: () async {
            await provider.loadNextPage(reset: true);
            _refreshController.refreshCompleted();
          },
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            itemCount: provider.pools.length,
            itemBuilder: _itemBuilder,
            physics: BouncingScrollPhysics(),
          ),
        ),
      );
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        return ValueListenableBuilder(
          valueListenable: isSearching,
          builder: (context, value, child) {
            return FloatingActionButton(
              child: value ? Icon(Icons.check) : Icon(Icons.search),
              onPressed: () async {
                setFocusToEnd(_tagController);
                if (value) {
                  provider.search.value = _tagController.text;
                  _bottomSheetController?.close();
                  provider.resetPages();
                } else {
                  _tagController.text = provider.search.value;
                  _bottomSheetController = Scaffold.of(context)
                      .showBottomSheet((context) => Container(
                            padding: EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 10),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _tagController,
                                    autofocus: true,
                                    maxLines: 1,
                                    inputFormatters: [
                                      LowercaseTextInputFormatter()
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Title',
                                    ),
                                  ),
                                ]),
                          ));
                  isSearching.value = true;
                  _bottomSheetController.closed.then((a) {
                    isSearching.value = false;
                  });
                }
              },
            ).build(context);
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pools'),
      ),
      body: bodyWidget(),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}

class PoolProvider extends DataProvider<Pool> {
  List<Pool> get pools => super.items;

  PoolProvider({
    String search,
  }) : super(search: search, provider: client.pools);
}
