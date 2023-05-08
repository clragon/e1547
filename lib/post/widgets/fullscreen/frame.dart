import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/post/widgets/fullscreen/appbar.dart';
import 'package:flutter/material.dart';

class PostFullscreenFrame extends StatelessWidget {
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
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ScaffoldFrame(
      controller: ScaffoldFrame.maybeOf(context),
      child: Theme(
        data: theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(
            systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.black26,
            ),
          ),
        ),
        child: ScaffoldFrameSystemUI(
          child: Builder(
            builder: (context) => AdaptiveScaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: ScaffoldFrameAppBar(
                child: PostFullscreenAppBar(post: post),
              ),
              drawer: drawer,
              endDrawer: endDrawer,
              bottomNavigationBar: post.getVideo(context) != null
                  ? VideoBar(
                      videoController: post.getVideo(context)!,
                    )
                  : null,
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  ScaffoldFrameController controller =
                      ScaffoldFrame.of(context);
                  controller.toggleFrame();
                  if ((post.getVideo(context)?.value.isPlaying ?? false) &&
                      controller.visible) {
                    controller.hideFrame(duration: const Duration(seconds: 2));
                  }
                },
                child: Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.center,
                  children: [
                    child,
                    if (post.getVideo(context) != null)
                      VideoButton(
                        videoController: post.getVideo(context)!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
