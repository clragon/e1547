import 'dart:math';

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
  final ImageSize size;

  /// Whether to display progress while the the image is loading.
  final bool showProgress;

  /// Whether the preview image should be displayed while sample is loading.
  /// Has no effect if [ImageSize] is not [ImageSize.sample].
  final bool withPreview;

  /// The cache size for this image.
  final int? cacheSize;

  /// The cache size of a previously loaded sample image.
  /// Used to bridge the gap between loading a downsized sample and the full sized one.
  /// Has no effect if [ImageSize] is not [ImageSize.sample].
  final int? sampleCacheSize;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double scale = min(constraints.maxWidth.toDouble(),
              constraints.maxHeight.toDouble());

          Widget image({
            required String url,
            ProgressIndicatorBuilder? progressIndicatorBuilder,
            bool stacked = false,
            int? cacheSize,
          }) {
            Duration fades =
                stacked ? const Duration() : const Duration(milliseconds: 500);

            Widget progressIndicator(context, url, progress) {
              return Center(
                child: SizedCircularProgressIndicator(
                  size: scale * 0.1,
                  value: progress.progress,
                  strokeWidth: scale * 0.01,
                ),
              );
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
              memCacheWidth: cacheSize ?? this.cacheSize,
            );
          }

          Widget previewWrapper(DownloadProgress progress, Widget child) {
            return AspectRatio(
              aspectRatio: post.file.width / post.file.height,
              child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: child),
                  if (progress.progress != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: LinearProgressIndicator(
                        value: progress.progress,
                        minHeight: scale * 0.01,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
            );
          }

          Widget cachedSample(Widget child) {
            if (sampleCacheSize != null) {
              return image(
                url: post.sample.url!,
                cacheSize: sampleCacheSize,
                progressIndicatorBuilder: (context, url, progress) => child,
              );
            }
            return child;
          }

          Widget? body() {
            switch (size) {
              case ImageSize.preview:
                return image(url: post.preview.url!);
              case ImageSize.sample:
                if (withPreview) {
                  return image(
                    stacked: true,
                    url: post.sample.url!,
                    progressIndicatorBuilder: (context, url, progress) =>
                        previewWrapper(
                      progress,
                      cachedSample(
                        image(
                          url: post.sample.url!,
                          cacheSize: sampleCacheSize,
                          progressIndicatorBuilder: (context, url, progress) =>
                              image(url: post.preview.url!),
                        ),
                      ),
                    ),
                  );
                } else {
                  return (image(url: post.sample.url!));
                }
              case ImageSize.file:
                return image(
                  stacked: true,
                  url: post.file.url!,
                  progressIndicatorBuilder: (context, url, progress) =>
                      previewWrapper(progress, image(url: post.sample.url!)),
                );
              default:
                return null;
            }
          }

          return DefaultTextStyle(
            style: TextStyle(fontSize: scale * 0.05),
            child: body()!,
          );
        },
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
