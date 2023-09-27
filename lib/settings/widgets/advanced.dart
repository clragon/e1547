import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_storage/shared_storage.dart';

class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => LimitedWidthLayout.builder(
        builder: (context) => Scaffold(
          appBar: const DefaultAppBar(
            title: Text('Advanced settings'),
            leading: BackButton(),
          ),
          body: ListView(
            primary: true,
            padding: defaultActionListPadding
                .add(LimitedWidthLayout.of(context).padding),
            children: [
              const ListTileHeader(title: 'Client'),
              ValueListenableBuilder<bool>(
                valueListenable: settings.upvoteFavs,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Upvote favorites'),
                  subtitle:
                      Text(value ? 'upvote and favorite' : 'favorite only'),
                  secondary: const Icon(Icons.arrow_upward),
                  value: value,
                  onChanged: (value) => settings.upvoteFavs.value = value,
                ),
              ),
              if (Platform.isAndroid)
                ValueListenableBuilder<String>(
                  valueListenable: settings.downloadPath,
                  builder: (context, value, child) => ListTile(
                    title: const Text('Download location'),
                    subtitle: Text(Uri.decodeComponent(Uri.parse(value).path)),
                    leading: const Icon(Icons.folder),
                    onTap: () async {
                      Uri? result =
                          await openDocumentTree(initialUri: Uri.parse(value));
                      if (result != null) {
                        settings.downloadPath.value = result.toString();
                      }
                    },
                  ),
                ),
              const Divider(),
              const ListTileHeader(title: 'Display'),
              ValueListenableBuilder<bool>(
                valueListenable: settings.showPostInfo,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Post info'),
                  subtitle:
                      Text(value ? 'info on post tiles' : 'image tiles only'),
                  secondary: const Icon(Icons.subtitles),
                  value: value,
                  onChanged: (value) => settings.showPostInfo.value = value,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: settings.muteVideos,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Video volume'),
                  subtitle: Text(value ? 'muted' : 'with sound'),
                  secondary: Icon(value ? Icons.volume_off : Icons.volume_up),
                  value: value,
                  onChanged: (value) => settings.muteVideos.value = value,
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Lockscreen'),
              ValueListenableBuilder<String?>(
                valueListenable: settings.appPin,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('PIN lock'),
                  subtitle:
                      Text(value != null ? 'PIN enabled' : 'PIN disabled'),
                  secondary: const Icon(Icons.pin),
                  value: value != null,
                  onChanged: (value) async {
                    if (value) {
                      String? pin = await registerPin(context);
                      if (pin != null) {
                        settings.appPin.value = pin;
                      }
                    } else {
                      settings.appPin.value = null;
                    }
                  },
                ),
              ),
              SubFuture<bool>(
                create: () => LocalAuthentication()
                    .getAvailableBiometrics()
                    .then((e) => e.isNotEmpty),
                builder: (context, snapshot) => ValueListenableBuilder<bool>(
                  valueListenable: settings.biometricAuth,
                  builder: (context, value, child) => SwitchListTile(
                    title: const Text('Biometric lock'),
                    subtitle: Text(
                        value ? 'biometrics enabled' : 'biometrics disabled'),
                    secondary: const Icon(Icons.fingerprint),
                    value: value,
                    onChanged: (snapshot.data ?? false)
                        ? (value) => settings.biometricAuth.value = value
                        : null,
                  ),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Beta'),
              ValueListenableBuilder<bool>(
                valueListenable: settings.showBeta,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Experimental features'),
                  subtitle:
                      Text(value ? 'preview enabled' : 'preview disabled'),
                  secondary: const Icon(Icons.auto_awesome),
                  value: value,
                  onChanged: (value) => settings.showBeta.value = value,
                ),
              ),
              ListTile(
                title: const Text('Restart migration'),
                subtitle: const Text('restart the migration process'),
                leading: const Icon(Icons.refresh),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Restart migration?'),
                      content: const Text(
                          'This will delete all your identities and restart the migration process. '),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
                            DatabaseMigrationProvider.of(context)
                                // ignore: deprecated_member_use_from_same_package
                                .restartMigration();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
