import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';

class PoolLoadingPage extends StatefulWidget {
  const PoolLoadingPage(this.id);

  final int id;

  @override
  State<PoolLoadingPage> createState() => _PoolLoadingPageState();
}

class _PoolLoadingPageState extends State<PoolLoadingPage> {
  late Future<Pool> pool = context.read<Client>().pool(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Pool>(
      future: pool,
      builder: (context, value) => PoolPage(pool: value),
      title: Text('Pool #${widget.id}'),
      onError: const Text('Failed to load pool'),
      onEmpty: const Text('Pool not found'),
    );
  }
}
