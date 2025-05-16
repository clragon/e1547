import 'package:flutter/material.dart';

class ReportFormDropdown<T> extends StatelessWidget {
  const ReportFormDropdown({
    super.key,
    required this.type,
    required this.types,
    required this.onChanged,
    this.isLoading = false,
  });

  final Map<T, String> types;
  final T type;
  final void Function(T? type) onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Type',
          border: OutlineInputBorder(),
        ),
        value: type,
        onChanged: isLoading ? null : onChanged,
        validator: (value) {
          if (value == null) {
            return 'Type cannot be empty';
          }
          return null;
        },
        items:
            types.keys
                .map<DropdownMenuItem<T>>(
                  (T value) => DropdownMenuItem<T>(
                    value: value,
                    child: Text(types[value]!),
                  ),
                )
                .toList(),
      ),
    );
  }
}
