import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

export 'package:e1547/client.dart' show validateCall;

class RefreshableProviderPage extends StatefulWidget {
  final WidgetBuilder builder;
  final DataProvider provider;
  final String refreshedText;
  final Widget onEmpty;
  final Widget onLoading;
  final Widget onError;
  final Widget drawer;
  final Widget floatingActionButton;
  final PreferredSizeWidget appBar;
  final ScrollController scrollController;
  final RefreshController refreshController;

  const RefreshableProviderPage({
    @required this.builder,
    @required this.appBar,
    @required this.provider,
    this.scrollController,
    this.refreshController,
    this.refreshedText,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.drawer,
    this.floatingActionButton,
  });

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
    widget.provider.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      refresh: () async {
        await widget.provider.loadNextPage(reset: true);
        return !widget.provider.isError;
      },
      builder: widget.builder,
      appBar: widget.appBar,
      isLoading: widget.provider.isLoading,
      isEmpty: widget.provider.items.isEmpty,
      isError: widget.provider.isError,
      refreshController: widget.refreshController,
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
  final WidgetBuilder builder;
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
  final RefreshController refreshController;
  final ScrollController scrollController;
  final Future<bool> Function() refresh;
  final Scaffold Function(
          BuildContext context, Widget child, ScrollController scrollController)
      pageBuilder;

  const RefreshablePage({
    @required this.refresh,
    @required this.builder,
    @required this.appBar,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.refreshController,
    this.scrollController,
    this.refreshedText,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.drawer,
    this.floatingActionButton,
  }) : this.pageBuilder = null;

  const RefreshablePage.pageBuilder({
    @required this.pageBuilder,
    @required this.refresh,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.builder,
    this.refreshController,
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
  RefreshController refreshController;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? ScrollController();
    refreshController = widget.refreshController ?? RefreshController();
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
        pageBuilder: (child) => SmartRefresher(
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
          child: child,
        ),
        builder: widget.builder,
      );
    }

    if (widget.pageBuilder != null) {
      return widget.pageBuilder(
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
  child,
}

class PageLoader extends StatelessWidget {
  final WidgetBuilder builder;
  final Widget Function(Widget child) pageBuilder;
  final Widget onLoading;
  final Widget onEmpty;
  final Widget onError;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;

  PageLoader({
    @required this.builder,
    @required this.isLoading,
    @required this.isEmpty,
    @required this.isError,
    this.pageBuilder,
    this.onLoading,
    this.onEmpty,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    PageLoaderState state = PageLoaderState.child;
    if (isEmpty) {
      if (isLoading) {
        state = PageLoaderState.loading;
      } else if (isError) {
        state = PageLoaderState.error;
      } else {
        state = PageLoaderState.empty;
      }
    }

    Widget child() {
      if (state == PageLoaderState.child) {
        return builder(context);
      } else {
        return SizedBox.shrink();
      }
    }

    return Stack(children: [
      Visibility(
        visible: state == PageLoaderState.loading,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedCircularProgressIndicator(size: 28),
              Padding(
                padding: EdgeInsets.all(20),
                child: onLoading ?? Text('Loading...'),
              ),
            ],
          ),
        ),
      ),
      pageBuilder?.call(child()) ?? child(),
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
