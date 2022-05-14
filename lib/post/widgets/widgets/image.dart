import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  final Post post;
  final BoxFit fit;
  final ImageSize size;
  final bool showProgress;
  final bool withPreview;

  const PostImageWidget({
    required this.post,
    required this.size,
    this.showProgress = true,
    this.withPreview = true,
    this.fit = BoxFit.contain,
  });

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
            );
          }

          Widget previewWrapper(DownloadProgress progress, Widget child) {
            return AspectRatio(
              aspectRatio: post.file.width / post.file.height,
              child: Stack(
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
                      image(url: post.preview.url!),
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

Widget defaultErrorBuilder(BuildContext context, String url, dynamic error) =>
    const Center(child: Icon(Icons.warning_amber_outlined));
