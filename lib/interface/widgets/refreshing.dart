import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableControllerPage<T extends RefreshableController>
    extends StatelessWidget {
  final Widget child;
  final Widget? refreshHeader;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final T controller;
  final ScrollController? scrollController;

  const RefreshableControllerPage({
    required this.child,
    required this.controller,
    this.appBar,
    this.scrollController,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

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
      child: (context) => child,
    );
  }
}

class RefreshablePageLoader extends StatelessWidget {
  final WidgetBuilder? builder;
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
  final Widget? onLoading;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final VoidCallback refresh;

  const RefreshablePageLoader({
    required this.refresh,
    required this.builder,
    required this.isLoading,
    required this.isEmpty,
    required this.isError,
    this.appBar,
    this.isBuilt,
    this.refreshController,
    this.scrollController,
    this.refreshHeader,
    this.initial,
    this.onLoading,
    this.onEmpty,
    this.onEmptyIcon,
    this.onError,
    this.onErrorIcon,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return PageLoader(
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
        child: (context) => child,
      ),
      builder: builder,
    );
  }
}

class RefreshablePage extends StatefulWidget {
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
  final String? refreshingText;
  final String? completeText;

  const RefreshablePageDefaultHeader({this.completeText, this.refreshingText});

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      refreshingText: refreshingText,
      completeText: completeText,
    );
  }
}
