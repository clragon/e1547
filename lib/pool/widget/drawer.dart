import 'package:e1547/pool/pool.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PoolOrderSwitch extends StatelessWidget {
  const PoolOrderSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final params = context.watch<PoolPostParams>();
    return SwitchListTile(
      secondary: const Icon(Icons.sort),
      title: const Text('Pool order'),
      subtitle: Text(params.orderByOldest ? 'oldest first' : 'newest first'),
      value: params.orderByOldest,
      onChanged: (value) {
        params.orderByOldest = value;
        Navigator.of(context).maybePop();
      },
    );
  }
}

class PostReaderModeSwitch extends StatelessWidget {
  const PostReaderModeSwitch({
    super.key,
    required this.value,
    required this.onChange,
  });

  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: const Icon(Icons.auto_stories),
    title: const Text('Reader mode'),
    subtitle: Text(value ? 'large images' : 'normal grid'),
    value: value,
    onChanged: onChange,
  );
}
