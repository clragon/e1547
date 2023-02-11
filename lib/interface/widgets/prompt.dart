import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

enum PromptType {
  dialog,
  sheet,
}

PromptType getPlatformPrompType() {
  if ([Platform.isAndroid, Platform.isIOS].any((e) => e)) {
    return PromptType.sheet;
  } else {
    return PromptType.dialog;
  }
}

Future<T?> showRawPrompt<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  PromptType? type,
}) async {
  switch (type ?? getPlatformPrompType()) {
    case PromptType.dialog:
      return showDialog<T>(
        context: context,
        builder: builder,
      );
    case PromptType.sheet:
      return showDefaultSlidingBottomSheet<T>(
        context,
        (context, state) => builder(context),
      );
  }
}

Future<T?> showPrompt<T>({
  required BuildContext context,
  required Widget body,
  Widget? title,
  PromptType? type,
}) {
  return showRawPrompt<T>(
    context: context,
    type: type,
    builder: (context) => PromptBody(
      title: title,
      body: body,
      type: type,
    ),
  );
}

class PromptBody extends StatelessWidget {
  const PromptBody({
    super.key,
    required this.body,
    this.title,
    this.type,
  });

  final Widget? title;
  final Widget body;
  final PromptType? type;

  @override
  Widget build(BuildContext context) {
    switch (type ?? getPlatformPrompType()) {
      case PromptType.dialog:
        return SimpleDialog(
          title: title,
          children: [body],
        );
      case PromptType.sheet:
        return DefaultSheetBody(
          title: title,
          body: body,
        );
    }
  }
}

class PromptMenuButton<T> extends StatelessWidget {
  const PromptMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
    this.icon,
    this.iconSize,
    this.enabled = true,
    this.color,
    this.type,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final bool enabled;
  final Color? color;
  final double? iconSize;
  final PromptType? type;

  @override
  Widget build(BuildContext context) {
    switch (type ?? getPlatformPrompType()) {
      case PromptType.dialog:
        return PopupMenuButton<T>(
          itemBuilder: itemBuilder,
          onSelected: onSelected,
          tooltip: tooltip,
          padding: padding,
          icon: icon,
          enabled: enabled,
          color: color,
          iconSize: iconSize,
        );
      case PromptType.sheet:
        return IconButton(
          icon: icon ?? Icon(Icons.adaptive.more),
          padding: padding,
          iconSize: iconSize,
          color: color,
          tooltip: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
          onPressed: enabled
              ? () async => _showPromptMenuSheet<T>(
                    context: context,
                    itemBuilder: itemBuilder,
                  ).then<void>((value) {
                    if (value != null) {
                      onSelected?.call(value);
                    }
                  })
              : null,
        );
    }
  }
}

Future<T?> _showPromptMenuSheet<T>({
  required BuildContext context,
  required PopupMenuItemBuilder<T> itemBuilder,
}) async {
  return showPrompt<T>(
    context: context,
    type: PromptType.sheet,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: itemBuilder(context),
    ),
  );
}
