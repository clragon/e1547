import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/post/widgets/fullscreen/appbar.dart';
import 'package:flutter/material.dart';

class PostFullscreenFrame extends StatefulWidget {
  const PostFullscreenFrame({
    required this.child,
    required this.post,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
  });

  final Post post;
  final Widget child;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;

  @override
  State<PostFullscreenFrame> createState() => _PostFullscreenFrameState();
}

class _PostFullscreenFrameState extends State<PostFullscreenFrame> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame(
      controller: ScaffoldFrame.maybeOf(context),
      child: ScaffoldFrameSystemUI(
        child: Builder(
          builder: (context) => AdaptiveScaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: ScaffoldFrameAppBar(
              child: PostFullscreenAppBar(post: widget.post),
            ),
            drawer: widget.drawer,
            endDrawer: widget.endDrawer,
            bottomNavigationBar: widget.post.getVideo(context) != null
                ? VideoBar(
                    videoController: widget.post.getVideo(context)!,
                  )
                : null,
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                ScaffoldFrameController controller = ScaffoldFrame.of(context);
                controller.toggleFrame();
                if ((widget.post.getVideo(context)?.value.isPlaying ?? false) &&
                    controller.visible) {
                  controller.hideFrame(duration: const Duration(seconds: 2));
                }
              },
              child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: [
                  widget.child,
                  if (widget.post.getVideo(context) != null)
                    VideoButton(
                      videoController: widget.post.getVideo(context)!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
