import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

import 'preview.dart';

class PoolsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PoolsPageState();
  }
}

class _PoolsPageState extends State<PoolsPage> {
  PoolProvider provider = PoolProvider();
  TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<String> sheetController;

  void update() {
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    provider.pages.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    provider.pages.removeListener(update);
  }

  Widget itemBuilder(BuildContext context, int item) {
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

    return preview(provider.pools[item], provider);
  }

  @override
  Widget build(BuildContext context) {
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

    return RefreshableProviderPage(
      provider: provider,
      appBar: AppBar(
        title: Text('Pools'),
      ),
      child: ListView.builder(
        itemCount: provider.pools.length,
        itemBuilder: itemBuilder,
        physics: BouncingScrollPhysics(),
      ),
      onLoading: Text('Loading pools'),
      onEmpty: Text('No pools'),
      onError: Text('Failed to load pools'),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
