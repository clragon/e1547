import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'preview.dart';

class PoolsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PoolsPageState();
  }
}

class _PoolsPageState extends State<PoolsPage> {
  bool loading = true;
  PoolProvider provider = PoolProvider();
  TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<String> sheetController;
  ScrollController scrollController = ScrollController();
  RefreshController refreshController = RefreshController();

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Pool pool, PoolProvider provider) {
      return PoolPreview(pool, onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
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
            loading = true;
          } else {
            loading = false;
          }
        });
      }
    });

    Widget bodyWidget() {
      return PageLoader(
        onLoading: Text('Loading pools'),
        onEmpty: Text('No pools'),
        isLoading: loading,
        isEmpty: (!loading &&
            provider.pages.value.length == 1 &&
            provider.pages.value[0].length == 0),
        child: SmartRefresher(
          controller: refreshController,
          header: ClassicHeader(
            completeText: 'Refreshed pools!',
          ),
          onRefresh: () async {
            await provider.loadNextPage(reset: true);
            refreshController.refreshCompleted();
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
            void submit(String result) {
              provider.search.value = result;
              sheetController?.close();
            }

            return FloatingActionButton(
              child: value ? Icon(Icons.check) : Icon(Icons.search),
              onPressed: () async {
                setFocusToEnd(textController);
                if (value) {
                  submit(textController.text);
                } else {
                  textController.text = provider.search.value;
                  sheetController = Scaffold.of(context).showBottomSheet(
                    (context) => Padding(
                      padding:
                          EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                      child: TextField(
                        controller: textController,
                        autofocus: true,
                        maxLines: 1,
                        inputFormatters: [LowercaseTextInputFormatter()],
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        onSubmitted: submit,
                      ),
                    ),
                  );
                  isSearching.value = true;
                  sheetController.closed.then((a) {
                    isSearching.value = false;
                  });
                }
              },
            );
          },
        );
      });
    }

    return Scaffold(
      appBar: ScrollingAppbarFrame(
        child: AppBar(
          title: Text('Pools'),
        ),
        controller: scrollController,
      ),
      body: bodyWidget(),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
