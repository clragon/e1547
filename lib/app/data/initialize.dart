import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Future.wait([
    initializeAppInfo(),
    initializeSettings(),
    initializeHttpCache(),
  ]);
}
