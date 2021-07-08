import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';

import 'preview.dart';

class ThreadsPage extends StatefulWidget {
  ThreadsPage();

  @override
  State<StatefulWidget> createState() {
    return _ThreadsPageState();
  }
}

class _ThreadsPageState extends State<ThreadsPage> {
  ThreadProvider provider = ThreadProvider();
  TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<String> sheetController;

  Widget preview(Thread thread, ThreadProvider provider) {
    return ThreadPreview(thread, onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ThreadDetail(thread),
      ));
    });
  }

  Widget itemBuilder(BuildContext context, int item) {
    if (item == provider.items.length - 1) {
      provider.loadNextPage();
    }
    return preview(provider.items[item], provider);
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButtonWidget() {
      return Builder(
        builder: (context) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (context, value, child) {
              return FloatingActionButton(
                child: value ? Icon(Icons.check) : Icon(Icons.search),
                onPressed: () async {
                  setFocusToEnd(textController);
                  if (value) {
                    provider.search.value = textController.text;
                    sheetController?.close();
                  } else {
                    textController.text = provider.search.value;
                    sheetController = Scaffold.of(context).showBottomSheet(
                      (context) => Container(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          TextField(
                            controller: textController,
                            autofocus: true,
                            maxLines: 1,
                            inputFormatters: [LowercaseTextInputFormatter()],
                            decoration: InputDecoration(
                              labelText: 'Title',
                            ),
                          ),
                        ]),
                      ),
                    );
                    isSearching.value = true;
                    sheetController.closed.then((_) {
                      isSearching.value = false;
                    });
                  }
                },
              );
            },
          );
        },
      );
    }

    return RefreshableProviderPage(
      builder: (context) => ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: itemBuilder,
        physics: BouncingScrollPhysics(),
      ),
      appBar: AppBar(
        title: Text('Forum'),
      ),
      provider: provider,
      onLoading: Text('Loading threads'),
      onEmpty: Text('No threads'),
      onError: Text('Failed to load threads'),
      drawer: NavigationDrawer(),
      floatingActionButton: floatingActionButtonWidget(),
    );
  }
}
