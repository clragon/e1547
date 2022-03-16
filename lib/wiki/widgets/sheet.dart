import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'actions.dart';
import 'body.dart';

void wikiSheet({
  required BuildContext context,
  required String tag,
  PostController? controller,
}) {
  showSlidingBottomSheet(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      (context, sheetState) => WikiSheet(
        tag: tag,
        controller: controller,
      ),
    ),
  );
}

class WikiSheet extends StatelessWidget {
  final String tag;
  final PostController? controller;

  const WikiSheet({required this.tag, this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultSheetBody(
      title: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPage(tags: tag),
          ),
        ),
        child: Text(tagToTitle(tag)),
      ),
      actions: [
        if (controller != null)
          TagSearchActions(
            tag: tag,
            controller: controller!,
          ),
        TagListActions(
          tag: tag,
        ),
      ],
      body: WikiBody(
        tag: tag,
        controller: controller,
      ),
    );
  }
}
