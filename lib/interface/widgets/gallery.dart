import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class GalleryButtonWrapper extends StatelessWidget {
  const GalleryButtonWrapper({
    super.key,
    required this.child,
    required this.controller,
  });

  final PageController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (![
      Platform.isWindows,
      Platform.isMacOS,
      Platform.isLinux,
    ].any((e) => e)) return child;
    return Material(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: GalleryPageButton(
                  controller: controller,
                  direction: GalleryButtonDirection.left,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: GalleryPageButton(
                  controller: controller,
                  direction: GalleryButtonDirection.right,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum GalleryButtonDirection {
  left,
  right,
}

class GalleryPageButton extends StatefulWidget {
  const GalleryPageButton({
    super.key,
    required this.direction,
    required this.controller,
  });

  final GalleryButtonDirection direction;
  final PageController controller;

  @override
  State<GalleryPageButton> createState() => _GalleryPageButtonState();
}

class _GalleryPageButtonState extends State<GalleryPageButton> {
  bool dimButton = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.hasClients &&
          widget.controller.position.hasContentDimensions) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getIcon() {
      switch (widget.direction) {
        case GalleryButtonDirection.left:
          return const Icon(
            Icons.keyboard_arrow_left,
            shadows: [Shadow(blurRadius: 9)],
          );
        case GalleryButtonDirection.right:
          return const Icon(
            Icons.keyboard_arrow_right,
            shadows: [Shadow(blurRadius: 9)],
          );
      }
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        bool enabled = false;

        if (widget.controller.hasClients &&
            widget.controller.position.hasContentDimensions) {
          switch (widget.direction) {
            case GalleryButtonDirection.left:
              enabled = widget.controller.position.minScrollExtent <
                  widget.controller.position.pixels;
              break;
            case GalleryButtonDirection.right:
              enabled = widget.controller.position.maxScrollExtent >
                  widget.controller.position.pixels;
              break;
          }
        }

        return AnimatedOpacity(
          opacity: enabled ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: ExcludeFocus(
            excluding: !enabled,
            child: IgnorePointer(
              ignoring: !enabled,
              child: MouseRegion(
                onEnter: (event) => setState(() => dimButton = false),
                onExit: (event) => setState(() => dimButton = true),
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: dimTextColor(context, 0.4),
                    end: dimButton
                        ? dimTextColor(context, 0.4)
                        : Theme.of(context).iconTheme.color,
                  ),
                  duration: const Duration(milliseconds: 100),
                  builder: (context, value, child) => IconButton(
                    onPressed: () {
                      int page = widget.controller.page!.round();
                      switch (widget.direction) {
                        case GalleryButtonDirection.left:
                          page--;
                          break;
                        case GalleryButtonDirection.right:
                          page++;
                          break;
                      }
                      widget.controller.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: getIcon(),
                    color: value,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
