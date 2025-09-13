import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostFullscreenGallery extends StatelessWidget {
  const PostFullscreenGallery({
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
        builder: (context, state, query) => ScaffoldFrame(
          child: GalleryButtons(
            controller: pageController,
            child: PagedPageView<int, Post>(
              state: state.paging,
              fetchNextPage: query.getNextPage,
              onPageChanged: (index) {
                onPageChanged?.call(index);
                preloadPostImages(
                  context: context,
                  index: index,
                  posts: state.paging.items ?? [],
                  size: PostImageSize.file,
                );
              },
              builderDelegate: defaultPagedChildBuilderDelegate(
                onRetry: query.getNextPage,
                itemBuilder: (context, item, index) =>
                    PostFullscreen(post: item),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
