import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableControllerPage<T extends RefreshableController>
    extends StatelessWidget {
  RefreshableControllerPage({
    required Widget child,
    required this.controller,
    this.appBar,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  })  : builder = null,
        child = ((context) => child);

  const RefreshableControllerPage.builder({
    required this.child,
    required this.controller,
    this.builder,
    this.appBar,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

  final WidgetBuilder child;
  final WidgetChildBuilder? builder;
  final Widget? refreshHeader;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final T controller;

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      refreshHeader: refreshHeader,
      drawer: drawer,
      endDrawer: endDrawer,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      refreshController: controller.refreshController,
      refresh: () => controller.refresh(background: true, force: true),
      builder: builder,
      child: child,
    );
  }
}

class RefreshableLoadingPage extends StatelessWidget {
  const RefreshableLoadingPage({
    required this.refresh,
    required this.child,
    this.builder,
    required this.isError,
    required this.isLoading,
    required this.isEmpty,
    this.appBar,
    this.isBuilt,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
    this.initial,
    this.onEmpty,
    this.onEmptyIcon,
    this.onError,
    this.onErrorIcon,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

  final WidgetBuilder child;
  final WidgetChildBuilder? builder;
  final bool isLoading;
  final bool isEmpty;
  final bool isError;
  final bool? isBuilt;
  final bool? initial;
  final Widget? refreshHeader;
  final Widget? onEmpty;
  final Widget? onEmptyIcon;
  final Widget? onError;
  final Widget? onErrorIcon;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context) {
    return LoadingPage(
      onEmpty: onEmpty,
      onEmptyIcon: onEmptyIcon,
      onError: onError,
      onErrorIcon: onErrorIcon,
      isLoading: isLoading,
      isEmpty: isEmpty,
      isError: isError,
      isBuilt: isBuilt,
      pageBuilder: (context, child) => RefreshablePage(
        refreshController: refreshController,
        refreshHeader: refreshHeader,
        refresh: refresh,
        appBar: appBar,
        drawer: drawer,
        endDrawer: endDrawer,
        floatingActionButton: floatingActionButton,
        builder: builder,
        child: child,
      ),
      child: child,
    );
  }
}

class RefreshablePage extends StatefulWidget {
  const RefreshablePage({
    required this.refresh,
    required this.child,
    this.builder,
    this.appBar,
    this.refreshController,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  final WidgetBuilder child;
  final WidgetChildBuilder? builder;
  final Widget? refreshHeader;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final VoidCallback refresh;

  @override
  State<RefreshablePage> createState() => _RefreshablePageState();
}

class _RefreshablePageState extends State<RefreshablePage> {
  late RefreshController refreshController =
      widget.refreshController ?? RefreshController();

  @override
  void didUpdateWidget(covariant RefreshablePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshController != widget.refreshController) {
      if (oldWidget.refreshController == null) {
        refreshController.dispose();
      }
      refreshController = widget.refreshController ?? RefreshController();
    }
  }

  @override
  void dispose() {
    if (widget.refreshController == null) {
      refreshController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetChildBuilder builder = widget.builder ?? (context, child) => child;
    return AdaptiveScaffold(
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.appBar,
      body: builder(
        context,
        Builder(
          builder: (context) => SmartRefresher(
            // Fix for SmartRefresher.didUpdateWidget accessing properties on disposed controllers
            key: ValueKey(refreshController),
            controller: refreshController,
            onRefresh: widget.refresh,
            header:
                widget.refreshHeader ?? const RefreshablePageDefaultHeader(),
            child: widget.child(context),
          ),
        ),
      ),
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class RefreshablePageDefaultHeader extends StatelessWidget {
  const RefreshablePageDefaultHeader({this.completeText, this.refreshingText});

  final String? refreshingText;
  final String? completeText;

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      refreshingText: refreshingText,
      completeText: completeText,
    );
  }
}
