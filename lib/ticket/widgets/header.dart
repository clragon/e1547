import 'package:flutter/material.dart';

class ReportFormHeader extends StatelessWidget {
  final Widget title;
  final Widget? icon;

  const ReportFormHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 32, right: 32, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle(
            child: title,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 20,
                ),
          ),
          if (icon != null)
            IconTheme(
              data: IconThemeData(
                color: Colors.grey,
              ),
              child: icon!,
            ),
        ],
      ),
    );
  }
}
