import 'dart:math';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/post/widgets/detail/appbar.dart';
import 'package:flutter/material.dart';

class PostDetail extends StatelessWidget {
  const PostDetail({
    super.key,
    required this.post,
    this.onTapImage,
  });

  final Post post;
  final VoidCallback? onTapImage;

  Widget image(BuildContext context, BoxConstraints constraints) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight / 2),
            maxHeight: constraints.maxWidth > constraints.maxHeight
                ? max(400, constraints.maxHeight * 0.8)
                : double.infinity,
          ),
          child: AnimatedSize(
            duration: defaultAnimationDuration,
            child: PostDetailImageDisplay(
              post: post,
              onTap: () {
                PostVideoRoute.of(context).keepPlaying();
                if (!(context.read<PostEditingController>().editing) &&
                    onTapImage != null) {
                  onTapImage!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostFullscreen(post: post),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );

  Widget upperBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtistDisplay(post: post),
            DeletionDisplay(post: post),
            LikeDisplay(post: post),
            DescriptionDisplay(post: post),
          ],
        ),
      );

  Widget middleBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            PostEditorChild(
              shown: false,
              child: CommentDisplay(post: post),
            ),
          ],
        ),
      );

  Widget lowerBody(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            RelationshipDisplay(post: post),
            PostEditorChild(
              shown: false,
              child: PoolDisplay(post: post),
            ),
            PostEditorChild(
              shown: false,
              child: DenylistTagDisplay(post: post),
            ),
            TagDisplay(post: post),
            PostEditorChild(
              shown: false,
              child: FileDisplay(
                post: post,
              ),
            ),
            PostEditorChild(
              shown: true,
              child: RatingDisplay(
                post: post,
              ),
            ),
            SourceDisplay(post: post),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PostVideoRoute(
      post: post,
      child: PostHistoryConnector(
        post: post,
        child: PostEditor(
          post: post,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PostDetailAppBar(post: post),
            floatingActionButton: context.read<Client>().hasLogin
                ? PostDetailFloatingActionButton(post: post)
                : null,
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
                        image(context, constraints),
                        upperBody(context),
                        middleBody(context),
                        lowerBody(context),
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
                                      image(context, constraints),
                                      upperBody(context),
                                    ],
                                  ),
                                ),
                                SliverPostCommentSection(post: post),
                              ],
                            ),
                            SliverConstrainedCrossAxis(
                              maxExtent: sideBarWidth,
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 56,
                                    ),
                                    lowerBody(context),
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
          ),
        ),
      ),
    );
  }
}
