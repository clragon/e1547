import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableDataPage extends StatelessWidget {
  RefreshableDataPage({
    super.key,
    required Widget child,
    required this.controller,
    this.appBar,
    this.refreshHeader,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  }) : builder = null,
       child = ((context) => child);

  const RefreshableDataPage.builder({
    super.key,
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
  final DataController controller;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(controller),
      child: SubValue<RefreshController>(
        create: () => RefreshController(),
        builder: (context, refreshController) => RefreshablePage(
          refreshHeader: refreshHeader,
          drawer: drawer,
          endDrawer: endDrawer,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          refreshController: refreshController,
          refresh: (_) async {
            await controller.refresh(force: true, background: true);
            if (controller.error != null) {
              refreshController.refreshFailed();
            }
            refreshController.refreshCompleted();
          },
          builder: builder,
          child: child,
        ),
      ),
    );
  }
}

class RefreshableLoadingPage extends StatelessWidget {
  const RefreshableLoadingPage({
    super.key,
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
    this.onError,
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
  final Widget? onError;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final void Function(RefreshController controller) refresh;

  @override
  Widget build(BuildContext context) {
    return LoadingPage(
      onEmpty: onEmpty,
      onError: onError,
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

class RefreshablePage extends StatelessWidget {
  const RefreshablePage({
    super.key,
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
  final void Function(RefreshController controller) refresh;

  @override
  Widget build(BuildContext context) {
    return SubDefault<RefreshController>(
      value: refreshController,
      create: () => RefreshController(),
      builder: (context, refreshController) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f5): () => refreshController
              .requestRefresh(duration: const Duration(milliseconds: 100)),
        },
        child: FocusScope(
          autofocus: true,
          child: AdaptiveScaffold(
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            appBar: appBar,
            body: (builder ?? (context, child) => child)(
              context,
              Builder(
                builder: (context) => SmartRefresher(
                  // Fix for SmartRefresher.didUpdateWidget accessing properties on disposed controllers
                  key: ValueKey(refreshController),
                  controller: refreshController,
                  onRefresh: () => refresh(refreshController),
                  header: refreshHeader ?? const RefreshablePageDefaultHeader(),
                  child: child(context),
                ),
              ),
            ),
            drawer: drawer,
            endDrawer: endDrawer,
            floatingActionButton: floatingActionButton,
          ),
        ),
      ),
    );
  }
}

class RefreshablePageDefaultHeader extends StatelessWidget {
  const RefreshablePageDefaultHeader({
    super.key,
    this.completeText,
    this.refreshingText,
  });

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
