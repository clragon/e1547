import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class Client {
  Client({required this.dio, required this.identity, required this.traits});

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;

  late final AccountClient account = AccountClient(
    dio: dio,
    identity: identity,
    traits: traits,
    postClient: posts,
  );

  late final PostClient posts = PostClient(dio: dio);

  void dispose() {
    dio.close();
    for (final client in [account, posts]) {
      try {
        (client as dynamic).dispose();
        // ignore: avoid_catching_errors
      } on NoSuchMethodError {
        // skip
      }
    }
  }
}
