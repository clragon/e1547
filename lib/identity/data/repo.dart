import 'package:e1547/identity/data/client.dart';
import 'package:e1547/identity/data/identity.dart';
import 'package:e1547/stream/stream.dart';

class IdentityRepo {
  IdentityRepo({required this.client});

  final IdentityClient client;

  StreamFuture<int> length() => client.length();

  StreamFuture<Identity?> getOrNull(int id) => client.getOrNull(id);

  StreamFuture<Identity> get(int id) => client.get(id);

  StreamFuture<List<Identity>> page({
    required int page,
    int? limit,
    String? nameRegex,
    String? hostRegex,
  }) => client.page(
    page: page,
    limit: limit,
    nameRegex: nameRegex,
    hostRegex: hostRegex,
  );

  StreamFuture<List<Identity>> all({String? nameRegex, String? hostRegex}) =>
      client.all(nameRegex: nameRegex, hostRegex: hostRegex);

  Future<Identity> add(IdentityRequest item) => client.add(item);

  Future<void> addAll(List<IdentityRequest> items) => client.addAll(items);

  Future<void> remove(Identity item) => client.remove(item);

  Future<void> removeAll(List<Identity> items) => client.removeAll(items);

  Future<void> replace(Identity item) => client.replace(item);
}
