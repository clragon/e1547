import 'package:e1547/interface/interface.dart';
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
          if (wiki.otherNames case final otherNames?)
            textInfoRow(
              'alias',
              otherNames.join(', '),
            ),
          textInfoRow(
            'created',
            DateFormatting.dateTime(wiki.createdAt.toLocal()),
          ),
          textInfoRow(
            'updated',
            DateFormatting.dateTime(
              (wiki.updatedAt ?? wiki.createdAt).toLocal(),
            ),
          ),
          if (wiki.isLocked case final isLocked?)
            textInfoRow(
              'locked',
              isLocked ? 'yes' : 'no',
            ),
        ],
      ),
    );
  }
}
