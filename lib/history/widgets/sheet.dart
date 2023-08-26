import 'package:e1547/app/app.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:flutter/material.dart';

Future<void> historySheet({
  required BuildContext context,
  required History entry,
}) async {
  return showDefaultSlidingBottomSheet(
    context,
    (context, sheetState) => HistorySheet(
      entry: entry,
    ),
  );
}

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key, required this.entry});

  final History entry;

  @override
  Widget build(BuildContext context) {
    VoidCallback? onTap = parseLinkOnTap(context, entry.link);
    return DefaultSheetBody(
      title: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            InkWell(
              onTap: onTap != null
                  ? () {
                      Navigator.of(context).maybePop();
                      onTap();
                    }
                  : null,
              child: Text(entry.getName(context)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: entry.subtitle != null
            ? DText(entry.subtitle!)
            : Center(
                child: Text(
                  'no description',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: dimTextColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
      ),
    );
  }
}
