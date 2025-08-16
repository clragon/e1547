import 'dart:math';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final domain = DomainRef.of(context);
    return QueryBuilder(
      query: domain.posts.useGet(id),
      builder: (context, state) {
        if (state.isError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
              forceMaterialTransparency: true,
            ),
            extendBodyBehindAppBar: true,
            body: Center(child: Text('Error: ${state.error}')),
          );
        }

        final post = state.data ?? FakePost();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(forceMaterialTransparency: true),
          body: MediaQuery.removeViewInsets(
            context: context,
            removeTop: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1000) {
                  return ListView(
                    primary: true,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      bottom: kBottomNavigationBarHeight + 24,
                    ),
                    children: [
                      PostDetailImageBox(post: post, constraints: constraints),
                      PostDetailHeader(post: post),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // CommentDisplay(post: post)
                            SizedBox(),
                          ],
                        ),
                      ),
                      PostDetailFooter(post: post),
                    ],
                  );
                } else {
                  double sideBarWidth;
                  if (constraints.maxWidth > 1400) {
                    sideBarWidth = 404;
                  } else {
                    sideBarWidth = 304;
                  }
                  return CustomScrollView(
                    primary: true,
                    slivers: [
                      SliverCrossAxisGroup(
                        slivers: [
                          SliverMainAxisGroup(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    PostDetailImageBox(
                                      post: post,
                                      constraints: constraints,
                                    ),
                                    PostDetailHeader(post: post),
                                  ],
                                ),
                              ),
                              // TODO: implement
                              // SliverPostCommentSection(post: post),
                            ],
                          ),
                          SliverConstrainedCrossAxis(
                            maxExtent: sideBarWidth,
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 56),
                                  PostDetailFooter(post: post),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class PostDetailImageBox extends StatelessWidget {
  const PostDetailImageBox({
    super.key,
    required this.post,
    required this.constraints,
    this.onTapImage,
  });

  final Post post;
  final BoxConstraints constraints;
  final VoidCallback? onTapImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (constraints.maxHeight / 2),
          maxHeight: constraints.maxWidth > constraints.maxHeight
              ? max(400, constraints.maxHeight * 0.8)
              : double.infinity,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: PostDetailImageDisplay(
            post: post,
            onTap: () {
              // TODO: implement
            },
          ),
        ),
      ),
    );
  }
}

class PostDetailHeader extends StatelessWidget {
  const PostDetailHeader({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistDisplay(post: post),
          // DeletionDisplay(post: post),
          LikeDisplay(post: post),
          // DescriptionDisplay(post: post),
        ],
      ),
    );
  }
}

class PostDetailFooter extends StatelessWidget {
  const PostDetailFooter({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // RelationshipDisplay(post: post),
          // PoolDisplay(post: post),
          // DenylistTagDisplay(post: post),
          // TagDisplay(post: post),
          // FileDisplay(post: post),
          // RatingDisplay(post: post),
          // SourceDisplay(post: post),
          SizedBox(),
        ],
      ),
    );
  }
}
