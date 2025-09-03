import 'package:flutter/material.dart';

class MultiSelectFormField<T> extends StatefulWidget {
  const MultiSelectFormField({
    super.key,
    required this.options,
    required this.valueMapper,
    required this.titleMapper,
    this.value,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.icon,
  });

  final List<T> options;
  final String? Function(T) valueMapper;
  final String Function(T) titleMapper;
  final Set<T>? value;
  final ValueChanged<Set<T>>? onChanged;
  final InputDecoration decoration;
  final Widget? icon;

  @override
  State<MultiSelectFormField<T>> createState() =>
      _MultiSelectFormFieldState<T>();
}

class _MultiSelectFormFieldState<T> extends State<MultiSelectFormField<T>> {
  late final TextEditingController _controller;
  Set<T> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.from(widget.value ?? {});
    _controller = TextEditingController(text: _getDisplayText());
  }

  @override
  void didUpdateWidget(MultiSelectFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValues = Set.from(widget.value ?? {});
      _controller.text = _getDisplayText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDisplayText() {
    if (_selectedValues.isEmpty) {
      return '';
    }
    return _selectedValues.map(widget.titleMapper).join(', ');
  }

  void _toggleOption(T option) {
    setState(() {
      if (_selectedValues.contains(option)) {
        _selectedValues.remove(option);
      } else {
        _selectedValues.add(option);
      }
      _controller.text = _getDisplayText();
      widget.onChanged?.call(_selectedValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T?>(
      controller: _controller,
      expandedInsets: EdgeInsets.zero,
      enableSearch: false,
      requestFocusOnTap: false,
      closeBehavior: DropdownMenuCloseBehavior.none,
      label: widget.decoration.labelText != null
          ? Text(widget.decoration.labelText!)
          : null,
      hintText: _selectedValues.isEmpty ? 'Select options...' : null,
      trailingIcon: widget.icon,
      inputDecorationTheme: InputDecorationTheme(
        border: widget.decoration.border,
        enabledBorder: widget.decoration.enabledBorder,
        focusedBorder: widget.decoration.focusedBorder,
        errorBorder: widget.decoration.errorBorder,
        focusedErrorBorder: widget.decoration.focusedErrorBorder,
        disabledBorder: widget.decoration.disabledBorder,
        contentPadding: widget.decoration.contentPadding,
      ),
      menuStyle: MenuStyle(
        maximumSize: WidgetStateProperty.all(const Size.fromHeight(300)),
      ),
      dropdownMenuEntries: [
        for (final option in widget.options)
          DropdownMenuEntry<T?>(
            value: option,
            label: '',
            labelWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IgnorePointer(
                    child: Checkbox(
                      value: _selectedValues.contains(option),
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.titleMapper(option),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      onSelected: (option) {
        if (option == null) return;
        _toggleOption(option);
      },
    );
  }
}
