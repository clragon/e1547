import 'package:e1547/pool/pool.dart';

extension Linking on Pool {
  String get link => getPoolLink(id);
}

String getPoolLink(int id) => '/pools/$id';
