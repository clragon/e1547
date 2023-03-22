import 'package:e1547/client/client.dart';

Future<CookiesService> initializeCookiesService(List<String> hosts) async {
  final service = CookiesService();
  await service.loadAll(
    hosts.map((e) => Uri.https(e).toString()).toList(),
  );
  return service;
}
