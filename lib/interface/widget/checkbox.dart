import 'package:flutter/material.dart';

class CheckboxFormField extends StatelessWidget {
  const CheckboxFormField({
    super.key,
    this.label,
    this.title,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.decoration,
  });

  final String? label;
  final Widget? title;
  final bool? value;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration =
        this.decoration ?? const InputDecoration(border: OutlineInputBorder());
    return InkWell(
      onTap: () {
        bool? updated;
        if (tristate) {
          updated = switch (value) {
            false => true,
            true => null,
            null => false,
          };
        } else {
          assert(value != null, 'Checkbox value cannot be null!');
          updated = !value!;
        }
        onChanged?.call(updated);
      },
      child: InputDecorator(
        decoration: decoration.copyWith(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Checkbox(
                  tristate: tristate,
                  value: value,
                  onChanged: onChanged,
                ),
              ),
              if (decoration.suffixIcon != null) decoration.suffixIcon!,
            ],
          ),
        ),
        child:
            title != null
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!,
                    child: title!,
                  ),
                )
                : null,
      ),
    );
  }
}
