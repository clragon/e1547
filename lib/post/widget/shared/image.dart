import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/theme/theme.dart';
import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  /// Displays the image of a post.
  ///
  /// Provides various preview options while loading.
  const PostImageWidget({
    super.key,
    required this.post,
    required this.size,
    this.showProgress = true,
    this.withLowRes = true,
    this.fit = BoxFit.contain,
    this.cacheSize,
    this.lowResCacheSize,
  });

  /// The post which provides the image.
  final Post post;

  /// How the image should be fit.
  final BoxFit fit;

  /// The image size to be selected from that post (preview, sample, file).
  final PostImageSize size;

  /// Whether to display progress while the the image is loading.
  final bool showProgress;

  /// Whether an already loaded lower resolution image should be displayed while the image is loading.
  final bool withLowRes;

  /// The cache size for this image.
  final int? cacheSize;

  /// The cache size of a previously loaded lower resolution image.
  /// Used to bridge the gap between loading a downsized image and the full sized one.
  final int? lowResCacheSize;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          double aspectRatio = post.width / post.height;

          return switch (size) {
            PostImageSize.preview => RawPostImageWidget(
                post: post,
                size: PostImageSize.preview,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
              ),
            PostImageSize.sample => RawPostImageWidget(
                stacked: withLowRes,
                post: post,
                size: PostImageSize.sample,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
                progressIndicatorBuilder: withLowRes
                    ? (context, url, progress) => ImageProgressWrapper(
                          aspectRatio: aspectRatio,
                          progress: progress.progress,
                          child: lowResCacheSize != null
                              ? RawPostImageWidget(
                                  post: post,
                                  size: PostImageSize.sample,
                                  fit: fit,
                                  cacheSize: lowResCacheSize,
                                )
                              : RawPostImageWidget(
                                  post: post,
                                  size: PostImageSize.preview,
                                  fit: fit,
                                ),
                        )
                    : null,
              ),
            PostImageSize.file => RawPostImageWidget(
                stacked: true,
                post: post,
                size: PostImageSize.file,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
                progressIndicatorBuilder: (context, url, progress) =>
                    ImageProgressWrapper(
                  progress: progress.progress,
                  aspectRatio: aspectRatio,
                  child: RawPostImageWidget(
                    post: post,
                    size: PostImageSize.sample,
                    showProgress: showProgress,
                    fit: fit,
                    cacheSize: lowResCacheSize,
                  ),
                ),
              )
          };
        },
      ),
    );
  }
}

class RawPostImageWidget extends StatelessWidget {
  const RawPostImageWidget({
    super.key,
    required this.post,
    required this.size,
    this.fit,
    this.progressIndicatorBuilder,
    this.stacked = false,
    this.showProgress = true,
    this.cacheSize,
  });

  final Post post;
  final PostImageSize size;
  final BoxFit? fit;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final bool stacked;
  final bool showProgress;
  final int? cacheSize;

  @override
  Widget build(BuildContext context) {
    Duration fades =
        stacked ? Duration.zero : const Duration(milliseconds: 500);

    Widget progressIndicator(
      BuildContext context,
      String url,
      DownloadProgress progress,
    ) {
      return Container(
        height: 30,
        width: 30,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      );
    }

    String url = switch (size) {
          PostImageSize.preview => post.preview,
          PostImageSize.sample => post.sample,
          PostImageSize.file => post.file!
        } ??
        post.file!;
    Size dimensions = Size(post.width.toDouble(), post.height.toDouble());

    double aspectRatio = dimensions.width / dimensions.height;

    int? memCacheWidth;
    int? memCacheHeight;

    if (aspectRatio > 1) {
      memCacheHeight = cacheSize;
    } else {
      memCacheWidth = cacheSize;
    }

    return CachedNetworkImage(
      fit: fit,
      fadeInDuration: fades,
      fadeOutDuration: fades,
      imageUrl: url,
      errorWidget: stacked
          ? defaultErrorBuilder
          : (context, url, error) => const SizedBox.shrink(),
      progressIndicatorBuilder: showProgress || stacked
          ? progressIndicatorBuilder ?? progressIndicator
          : null,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      // TODO: use cacheManager from context
      // cacheManager: context.read<BaseCacheManager>(),
    );
  }
}

class ImageProgressWrapper extends StatefulWidget {
  const ImageProgressWrapper({
    super.key,
    required this.child,
    required this.aspectRatio,
    required this.progress,
  });

  /// The widget below this one in the tree.
  final Widget child;

  /// The aspect ratio of the image.
  final double aspectRatio;

  /// The download progress.
  final double? progress;

  @override
  State<ImageProgressWrapper> createState() => _ImageProgressWrapperState();
}

class _ImageProgressWrapperState extends State<ImageProgressWrapper> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(milliseconds: 1000),
      () {
        if (mounted) {
          setState(() => visible = true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: widget.child),
          if (widget.progress != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: Theme.of(context).animationTheme.defaultDuration,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A default error builder for cached network image.
/// Shows a centered icon.
Widget defaultErrorBuilder(BuildContext context, String url, dynamic error) =>
    const Center(child: Icon(Icons.warning_amber_outlined));
