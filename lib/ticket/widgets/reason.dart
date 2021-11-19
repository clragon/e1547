import 'package:e1547/ticket/ticket.dart';
import 'package:flutter/material.dart';

class ReportFormReason extends StatelessWidget {
  final bool isLoading;
  final TextEditingController controller;

  const ReportFormReason({required this.isLoading, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultFormPadding,
      child: TextFormField(
        enabled: !isLoading,
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Reason',
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        validator: (value) {
          if (value!.trim().isEmpty) {
            return 'Reason cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
