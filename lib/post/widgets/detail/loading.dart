import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostLoadingPage extends StatefulWidget {
  final int id;

  const PostLoadingPage(this.id);

  @override
  _PostLoadingPageState createState() => _PostLoadingPageState();
}

class _PostLoadingPageState extends State<PostLoadingPage> {
  late Future<PostController> controller =
      waitForFirstPage(singlePostController(widget.id));

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<PostController>(
      future: controller,
      builder: (context, value) => PostDetail(
        post: value.itemList!.first,
        controller: value,
      ),
      title: Text('Post #${widget.id}'),
      onError: Text('Failed to load post'),
      onEmpty: Text('Post not found'),
    );
  }
}

PostController singlePostController(int id) {
  late PostController controller;
  controller = PostController(
    provider: (search, page, force) async => page == controller.firstPageKey
        ? [await client.post(id, force: force)]
        : [],
    canSearch: false,
    denyMode: DenyListMode.plain,
  );
  return controller;
}

Future<T> waitForFirstPage<T extends DataController>(T controller) {
  Completer<T> completer = Completer<T>();

  void onUpdate() {
    switch (controller.value.status) {
      case PagingStatus.loadingFirstPage:
        // ignored
        break;
      case PagingStatus.ongoing:
      case PagingStatus.noItemsFound:
      case PagingStatus.completed:
        controller.removeListener(onUpdate);
        completer.complete(controller);
        break;
      case PagingStatus.firstPageError:
      case PagingStatus.subsequentPageError:
        controller.removeListener(onUpdate);
        completer.completeError(controller.error);
        break;
    }
  }

  controller.addListener(onUpdate);
  controller.notifyPageRequestListeners(controller.nextPageKey!);
  return completer.future;
}
