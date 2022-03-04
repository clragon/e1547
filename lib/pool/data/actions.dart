import 'package:e1547/pool/pool.dart';

extension Linking on Pool {
  Uri url(String host) => getPooltUri(host, id);

  String get search => 'pool:$id';
}

Uri getPooltUri(String host, int id) =>
    Uri(scheme: 'https', host: host, path: '/pools/$id');
