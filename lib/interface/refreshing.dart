import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'package:e1547/client.dart' show validateCall;

class RefreshableProviderPage extends StatefulWidget {
  final Widget child;
  final DataProvider provider;
  final String refreshedText;
  final Widget onEmpty;
  final Widget onLoading;
  final Widget onError;
  final Widget drawer;
  final Widget floatingActionButton;
  final PreferredSizeWidget appBar;
  final ScrollController scrollController;
  final Scaffold Function(
          BuildContext context, Widget child, ScrollController scrollController)
      builder;

  const RefreshableProviderPage({
    @required this.child,
    @required this.appBar,
    @required this.provider,
    this.scrollController,
    this.refreshedText,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.drawer,
    this.floatingActionButton,
  }) : this.builder = null;

  @override
  _RefreshableProviderPageState createState() =>
      _RefreshableProviderPageState();
}

class _RefreshableProviderPageState extends State<RefreshableProviderPage> {
  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    update();
    widget.provider.pages.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.pages.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      refresh: () async {
        await widget.provider.loadNextPage(reset: true);
        return !widget.provider.isError;
      },
      child: widget.child,
      appBar: widget.appBar,
      isLoading: widget.provider.isLoading,
      isEmpty: widget.provider.items.isEmpty,
      isError: widget.provider.isError,
      scrollController: widget.scrollController,
      refreshedText: widget.refreshedText,
      onLoading: widget.onLoading,
      onEmpty: widget.onEmpty,
      onError: widget.onError,
      floatingActionButton: widget.floatingActionButton,
      drawer: widget.drawer,
      initial: false,
    );
  }
}

class RefreshablePage extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool initial;
  final String refreshedText;
  final Widget onEmpty;
  final Widget onLoading;
  final Widget onError;
  final Widget drawer;
  final Widget floatingActionButton;
  final PreferredSizeWidget appBar;
  final ScrollController scrollController;
  final Future<bool> Function() refresh;
  final Scaffold Function(
          BuildContext context, Widget child, ScrollController scrollController)
      builder;

  const RefreshablePage({
    @required this.refresh,
    @required this.child,
    @required this.appBar,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.scrollController,
    this.refreshedText,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.drawer,
    this.floatingActionButton,
  }) : this.builder = null;

  const RefreshablePage.builder({
    @required this.builder,
    @required this.refresh,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.child,
    this.scrollController,
    this.refreshedText,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onError,
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
        onError: widget.onError,
        isLoading: widget.isLoading,
        isEmpty: widget.isEmpty,
        isError: widget.isError,
        child: SmartRefresher(
          primary: false,
          scrollController: scrollController,
          controller: refreshController,
          header: ClassicHeader(
            completeText: widget.refreshedText,
          ),
          onRefresh: () async {
            bool result = await widget.refresh();
            if (result) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
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
      return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          appBar: ScrollingAppbarFrame(
            child: widget.appBar,
            controller: scrollController,
          ),
          body: body(),
          drawer: widget.drawer,
          drawerEdgeDragWidth: defaultDrawerEdge(constraints.maxWidth),
          floatingActionButton: widget.floatingActionButton,
        );
      });
    }
  }
}

enum PageLoaderState {
  loading,
  empty,
  error,
  none,
}

class PageLoader extends StatelessWidget {
  final Widget child;
  final Widget onLoading;
  final Widget onEmpty;
  final Widget onError;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;

  PageLoader({
    @required this.child,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.onLoading,
    this.onEmpty,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    PageLoaderState state = PageLoaderState.none;
    if (isEmpty) {
      if (isLoading) {
        state = PageLoaderState.loading;
      } else if (isError) {
        state = PageLoaderState.error;
      } else {
        state = PageLoaderState.empty;
      }
    }

    return Stack(children: [
      Visibility(
        visible: state == PageLoaderState.loading,
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
                child: onLoading ?? Text('Loading...'),
              ),
            ],
          ),
        ),
      ),
      child,
      Visibility(
        visible: state == PageLoaderState.error,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: onError ?? Text('Failed to load items'),
              ),
            ],
          ),
        ),
      ),
      Visibility(
        visible: state == PageLoaderState.empty,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.clear,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: onEmpty ?? Text('No items'),
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
