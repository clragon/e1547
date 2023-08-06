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
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.black26,
          ),
        ),
      ),
      child: ScaffoldFrame(
        controller: ScaffoldFrame.maybeOf(context),
        child: ScaffoldFrameSystemUI(
          child: Builder(
            builder: (context) {
              VideoPlayer? player = post.getVideo(context);
              return AdaptiveScaffold(
                extendBodyBehindAppBar: true,
                extendBody: true,
                appBar: ScaffoldFrameAppBar(
                  child: PostFullscreenAppBar(post: post),
                ),
                drawer: drawer,
                endDrawer: endDrawer,
                bottomNavigationBar:
                    player != null ? VideoBar(player: player) : null,
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    ScaffoldFrameController controller =
                        ScaffoldFrame.of(context);
                    controller.toggleFrame();
                    if ((player?.state.playing ?? false) &&
                        controller.visible) {
                      controller.hideFrame(
                          duration: const Duration(seconds: 2));
                    }
                  },
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: [
                      child,
                      if (player != null) VideoButton(player: player),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
