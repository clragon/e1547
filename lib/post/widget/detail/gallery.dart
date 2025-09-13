import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostDetailGallery extends StatelessWidget {
  const PostDetailGallery({
    super.key,
    this.params,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
  }) : assert(
         initialPage == null || pageController == null,
         'Cannot pass both initialPage and pageController',
       );

  final QueryMap? params;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) => SubDefault<PageController>(
    value: pageController,
    create: () => PageController(initialPage: initialPage ?? 0),
    builder: (context, pageController) => ListenableProvider(
      create: (_) => PostParams(value: params),
      child: PostPageQueryBuilder(
        builder: (context, state, query) => PagedPageView(
          pageController: pageController,
          state: state.paging,
          fetchNextPage: query.getNextPage,
          builderDelegate: defaultPagedChildBuilderDelegate<Post>(
            onRetry: query.getNextPage,
            pageBuilder: (context, child) => Scaffold(
              appBar: const TransparentAppBar(child: DefaultAppBar()),
              body: child,
            ),
            onEmpty: const Text('No posts'),
            onError: const Text('Failed to load posts'),
            itemBuilder: (context, item, index) => SubScrollController(
              builder: (context, scrollController) => PrimaryScrollController(
                controller: scrollController,
                child: PostDetail(
                  post: item,
                  onTapImage: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostFullscreenGallery(
                        params: params,
                        initialPage: index,
                        onPageChanged: pageController.jumpToPage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          onPageChanged: (index) {
            onPageChanged?.call(index);
            preloadPostImages(
              context: context,
              index: index,
              posts: state.paging.items ?? [],
              size: PostImageSize.sample,
            );
          },
        ),
      ),
    ),
  );
}
