import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class AdvancedSettingsPage extends StatefulWidget {
  @override
  State createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout.builder(
      builder: (context) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('Advanced settings'),
          leading: BackButton(),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: defaultActionListPadding
              .add(LimitedWidthLayout.of(context)!.padding),
          children: [
            const SettingsHeader(title: 'Server'),
            ValueListenableBuilder<bool>(
              valueListenable: settings.upvoteFavs,
              builder: (context, value, child) => SwitchListTile(
                title: const Text('Upvote favorites'),
                subtitle: Text(value ? 'upvote and favorite' : 'favorite only'),
                secondary: const Icon(Icons.arrow_upward),
                value: value,
                onChanged: (value) => settings.upvoteFavs.value = value,
              ),
            ),
            const Divider(),
            const SettingsHeader(title: 'Display'),
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
            const SettingsHeader(title: 'Beta'),
            ValueListenableBuilder<bool>(
              valueListenable: settings.showBeta,
              builder: (context, value, child) => SwitchListTile(
                title: const Text('Experimental features'),
                subtitle: Text(value ? 'preview enabled' : 'preview disabled'),
                secondary: const Icon(Icons.auto_awesome),
                value: value,
                onChanged: (value) => settings.showBeta.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
