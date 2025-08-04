import 'package:e1547/stream/stream.dart';
import 'package:e1547/traits/data/client.dart';
import 'package:e1547/traits/data/traits.dart';

class TraitsRepo {
  TraitsRepo({required this.client});

  final TraitsClient client;

  StreamFuture<Traits?> getOrNull(int id) => client.getOrNull(id);

  StreamFuture<Traits> get(int id) => client.get(id);

  Future<Traits> add(TraitsRequest value) => client.add(value);

  Future<void> remove(Traits value) => client.remove(value);

  Future<void> replace(Traits value) => client.replace(value);
}
