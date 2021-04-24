import 'package:e1547/post.dart';
import 'package:e1547/wiki/pages/actions.dart';
import 'package:e1547/wiki/pages/body.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

void wikiSheet(
    {@required BuildContext context,
    @required String tag,
    PostProvider provider}) {
  showSlidingBottomSheet(
    context,
    builder: (BuildContext context) {
      return SlidingSheetDialog(
        duration: Duration(milliseconds: 400),
        isBackdropInteractable: true,
        cornerRadius: 16,
        minHeight: MediaQuery.of(context).size.height * 0.6,
        builder: (context, sheetState) {
          return WikiSheet(
            tag: tag,
            provider: provider,
          );
        },
        snapSpec: SnapSpec(
          snap: true,
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [
            0.6,
            SnapSpec.expanded,
          ],
        ),
      );
    },
  );
}

class WikiSheet extends StatelessWidget {
  final String tag;
  final PostProvider provider;

  WikiSheet({@required this.tag, this.provider});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchPage(tags: tag),
                      )),
                      child: Text(
                        tagToTitle(tag),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                ),
                if (provider != null)
                  TagSearchActions(
                    tag: tag,
                    provider: provider,
                  ),
                TagListActions(
                  tag: tag,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: WikiBody(
                tag: tag,
                provider: provider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
