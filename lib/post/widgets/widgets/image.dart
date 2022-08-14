import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  /// Displays the image of a post.
  ///
  /// Provides various preview options while loading.
  const PostImageWidget({
    required this.post,
    required this.size,
    this.showProgress = true,
    this.withPreview = true,
    this.fit = BoxFit.contain,
    this.cacheSize,
    this.sampleCacheSize,
  });

  /// The post which provides the image.
  final Post post;

  /// How the image should be fit.
  final BoxFit fit;

  /// The image size to be selected from that post (preview, sample, file).
  final PostImageSize size;

  /// Whether to display progress while the the image is loading.
  final bool showProgress;

  /// Whether the preview image should be displayed while sample is loading.
  /// Has no effect if [PostImageSize] is not [PostImageSize.sample].
  final bool withPreview;

  /// The cache size for this image.
  final int? cacheSize;

  /// The cache size of a previously loaded sample image.
  /// Used to bridge the gap between loading a downsized sample and the full sized one.
  /// Has no effect if [PostImageSize] is not [PostImageSize.sample].
  final int? sampleCacheSize;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          double aspectRatio = post.file.width / post.file.height;

          switch (size) {
            case PostImageSize.preview:
              return RawPostImageWidget(
                post: post,
                size: PostImageSize.preview,
                showProgress: showProgress,
                fit: fit,
                cacheSize: cacheSize,
              );
            case PostImageSize.sample:
              if (withPreview) {
                return RawPostImageWidget(
                  stacked: true,
                  post: post,
                  size: PostImageSize.sample,
                  showProgress: showProgress,
                  fit: fit,
                  cacheSize: cacheSize,
                  progressIndicatorBuilder: (context, url, progress) =>
                      ImageProgressWrapper(
                    aspectRatio: aspectRatio,
                    progress: progress.progress,
                    child: sampleCacheSize != null
                        ? RawPostImageWidget(
                            post: post,
                            size: PostImageSize.sample,
                            fit: fit,
                            cacheSize: sampleCacheSize,
                          )
                        : RawPostImageWidget(
                            post: post,
                            size: PostImageSize.preview,
                            fit: fit,
                          ),
                  ),
                );
              } else {
                return RawPostImageWidget(
                  post: post,
                  size: PostImageSize.sample,
                  showProgress: showProgress,
                  fit: fit,
                  cacheSize: cacheSize,
                );
              }
            case PostImageSize.file:
              return RawPostImageWidget(
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
                    fit: fit,
                  ),
                ),
              );
          }
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
        stacked ? const Duration() : const Duration(milliseconds: 500);

    Widget progressIndicator(context, url, progress) {
      return Center(
        child: SizedCircularProgressIndicator(
          size: 30,
          value: progress.progress,
        ),
      );
    }

    String url;
    Size dimensions;
    switch (size) {
      case PostImageSize.preview:
        url = post.preview.url!;
        dimensions =
            Size(post.preview.width.toDouble(), post.preview.height.toDouble());
        break;
      case PostImageSize.sample:
        url = post.sample.url!;
        dimensions =
            Size(post.sample.width.toDouble(), post.sample.height.toDouble());
        break;
      case PostImageSize.file:
        url = post.file.url!;
        dimensions =
            Size(post.file.width.toDouble(), post.file.height.toDouble());
        break;
    }

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
    );
  }
}

class ImageProgressWrapper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: child),
          if (progress != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
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

class SampleCacheSize {
  /// Configures the post sample image cache size for a subtree.
  const SampleCacheSize(this.size);

  /// The cache size of the image.
  final int? size;
}

class SampleCacheSizeProvider extends SubProvider0<SampleCacheSize> {
  /// Provides a sample image cache size to a subtree.
  SampleCacheSizeProvider({required int? size, super.child, super.builder})
      : super(
          create: (context) => SampleCacheSize(size),
          selector: (context) => [size],
        );

  /// Removes the sample cache size for a subtree.
  SampleCacheSizeProvider.none({super.child, super.builder})
      : super(
          create: (context) => const SampleCacheSize(null),
        );
}
