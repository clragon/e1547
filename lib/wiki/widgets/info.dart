import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WikiInfo extends StatelessWidget {
  const WikiInfo({super.key, required this.wiki});

  final Wiki wiki;

  @override
  Widget build(BuildContext context) {
    Widget textInfoRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      );
    }

    return DefaultTextStyle(
      style: TextStyle(
        color: dimTextColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow('category', TagCategory.byId(wiki.categoryId).name),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('id'),
              InkWell(
                child: Text(
                  '#${wiki.id}',
                ),
                onLongPress: () async {
                  ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  Clipboard.setData(ClipboardData(
                    text: wiki.id.toString(),
                  ));
                  await Navigator.of(context).maybePop();
                  messenger.showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text('Copied wiki id #${wiki.id}'),
                  ));
                },
              ),
            ],
          ),
          textInfoRow(
            'alias',
            wiki.otherNames.join(', '),
          ),
          textInfoRow(
            'created',
            formatDateTime(wiki.createdAt.toLocal()),
          ),
          textInfoRow(
            'updated',
            wiki.updatedAt != null
                ? formatDateTime(
                    wiki.updatedAt!.toLocal(),
                  )
                : 'never',
          ),
          textInfoRow(
            'locked',
            wiki.isLocked ? 'yes' : 'no',
          ),
        ],
      ),
    );
  }
}
