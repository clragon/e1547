import 'package:flutter/material.dart';

import 'padding.dart';

class ReportFormHeader extends StatelessWidget {
  final Widget title;
  final Widget? icon;

  const ReportFormHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultFormPadding
          .add(const EdgeInsets.only(left: 8, right: 8, bottom: 12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontSize: 20,
                ),
            child: title,
          ),
          if (icon != null)
            IconTheme(
              data: const IconThemeData(
                color: Colors.grey,
              ),
              child: icon!,
            ),
        ],
      ),
    );
  }
}
