import 'dart:async';

import 'package:flutter/material.dart';

// This widget would be useful at the very top of the widget tree
// right below MaterialApp, so that transitions between links
// work correctly (snap and fade).
// but it requires access to an Overlay,
// so this is not possible right now.
// See: https://github.com/flutter/flutter/issues/129677
class LinkPreviewProvider extends StatefulWidget {
  const LinkPreviewProvider({super.key, required this.child});

  final Widget child;

  static LinkPreviewProviderState of(BuildContext context) => maybeOf(context)!;

  static LinkPreviewProviderState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<LinkPreviewProviderState>();

  @override
  LinkPreviewProviderState createState() => LinkPreviewProviderState();
}

class LinkPreviewProviderState extends State<LinkPreviewProvider> {
  final ValueNotifier<String?> _linkNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => LinkOverlay(notifier: _linkNotifier),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Overlay.of(context).insert(overlayEntry);
    });
  }

  // ignore: use_setters_to_change_properties
  void showLink(String link) => _linkNotifier.value = link;

  void hideLink() {
    _linkNotifier.value = null;
  }

  @override
  void dispose() {
    _linkNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class LinkOverlay extends StatefulWidget {
  const LinkOverlay({super.key, required this.notifier});

  final ValueNotifier<String?> notifier;

  @override
  State<LinkOverlay> createState() => _LinkOverlayState();
}

class _LinkOverlayState extends State<LinkOverlay>
    with SingleTickerProviderStateMixin {
  String? _currentLink;
  Timer? _activationTimer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    widget.notifier.addListener(_linkChanged);
  }

  void _linkChanged() {
    _activationTimer?.cancel();

    if (widget.notifier.value != null) {
      if (_currentLink != null) {
        setState(() {
          _currentLink = widget.notifier.value;
          _controller.value = 1.0;
        });
      } else {
        _activationTimer = Timer(const Duration(milliseconds: 300), () {
          setState(() {
            _currentLink = widget.notifier.value;
            _controller.stop();
            _controller.forward(from: 0);
          });
        });
      }
    } else {
      _controller.stop();
      _controller.reverse().then((_) => _currentLink = null);
    }
  }

  @override
  void dispose() {
    _activationTimer?.cancel();
    _controller.dispose();
    widget.notifier.removeListener(_linkChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: FadeTransition(
        opacity: _controller,
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(4)),
          child: _currentLink != null
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(_currentLink!),
                )
              : Container(),
        ),
      ),
    );
  }
}
