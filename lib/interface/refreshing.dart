import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshablePage extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final bool isEmpty;
  final bool initial;
  final String refreshedText;
  final Widget onEmpty;
  final Widget onLoading;
  final Widget drawer;
  final Widget floatingActionButton;
  final PreferredSizeWidget appBar;
  final ScrollController scrollController;
  final Future<void> Function() refresh;
  final Scaffold Function(
          BuildContext context, Widget child, ScrollController scrollController)
      builder;

  const RefreshablePage({
    @required this.refresh,
    @required this.child,
    @required this.appBar,
    @required this.isLoading,
    @required this.isEmpty,
    this.scrollController,
    this.refreshedText,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.drawer,
    this.floatingActionButton,
  }) : this.builder = null;

  const RefreshablePage.builder({
    @required this.builder,
    @required this.refresh,
    @required this.isLoading,
    @required this.isEmpty,
    this.child,
    this.scrollController,
    this.refreshedText,
    this.initial,
    this.onLoading,
    this.onEmpty,
  })  : this.appBar = null,
        this.drawer = null,
        this.floatingActionButton = null;

  @override
  _RefreshablePageState createState() => _RefreshablePageState();
}

class _RefreshablePageState extends State<RefreshablePage> {
  RefreshController refreshController = RefreshController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? ScrollController();
    if (widget.initial ?? false) {
      widget.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return PageLoader(
        onLoading: widget.onLoading,
        onEmpty: widget.onEmpty,
        isLoading: widget.isLoading,
        isEmpty: !widget.isLoading && widget.isEmpty,
        child: SmartRefresher(
          primary: false,
          scrollController: scrollController,
          controller: refreshController,
          header: ClassicHeader(
            completeText: widget.refreshedText,
          ),
          onRefresh: () async {
            widget
                .refresh()
                .then((_) => refreshController.refreshCompleted())
                .catchError((_) => refreshController.refreshFailed);
          },
          physics: BouncingScrollPhysics(),
          child: widget.child,
        ),
      );
    }

    if (widget.builder != null) {
      return widget.builder(
        context,
        body(),
        scrollController,
      );
    } else {
      return Scaffold(
        appBar: ScrollingAppbarFrame(
          child: widget.appBar,
          controller: scrollController,
        ),
        body: body(),
        drawer: widget.drawer,
        floatingActionButton: widget.floatingActionButton,
      );
    }
  }
}

class PageLoader extends StatelessWidget {
  final Widget child;
  final Widget onLoading;
  final Widget onEmpty;
  final bool isLoading;
  final bool isEmpty;

  PageLoader({
    @required this.child,
    @required this.isLoading,
    @required this.isEmpty,
    this.onLoading,
    this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Visibility(
        visible: isLoading,
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
                child: onLoading ?? Text('loading...'),
              ),
            ],
          ),
        ),
      ),
      child,
      Visibility(
        visible: (isEmpty),
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
                child: onEmpty ?? Text('no items'),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class ScrollingAppbarFrame extends StatelessWidget with PreferredSizeWidget {
  final ScrollController controller;
  final Widget child;

  const ScrollingAppbarFrame({@required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: controller != null
          ? () => controller.animateTo(controller.position.minScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn)
          : null,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
