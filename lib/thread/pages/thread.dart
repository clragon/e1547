import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'preview.dart';

class ThreadsPage extends StatefulWidget {
  ThreadsPage();

  @override
  State<StatefulWidget> createState() {
    return _ThreadsPageState();
  }
}

class _ThreadsPageState extends State<ThreadsPage> {
  bool _loading = true;
  ThreadProvider provider = ThreadProvider();
  TextEditingController _tagController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<String> _bottomSheetController;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Thread thread, ThreadProvider provider) {
      return ThreadPreview(thread, onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ThreadDetail(thread),
        ));
      });
    }

    if (item == provider.threads.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.threads.length) {
      return preview(provider.threads[item], provider);
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
        onLoading: Text('Loading threads'),
        onEmpty: Text('No threads'),
        isLoading: _loading,
        isEmpty: (!_loading &&
            provider.pages.value.length == 1 &&
            provider.pages.value[0].length == 0),
        child: SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            refreshingText: 'Refreshing...',
            completeText: 'Refreshed threads!',
          ),
          onRefresh: () async {
            await provider.loadNextPage(reset: true);
            _refreshController.refreshCompleted();
          },
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            itemCount: provider.threads.length,
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
        title: Text('Forum'),
      ),
      body: bodyWidget(),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
