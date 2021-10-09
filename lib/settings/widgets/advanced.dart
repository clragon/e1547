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
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced settings'),
        leading: BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        physics: BouncingScrollPhysics(),
        children: [
          SettingsHeader(title: 'Display'),
          ValueListenableBuilder<bool>(
            valueListenable: settings.beta,
            builder: (context, value, child) => SafeCrossFade(
              showChild: value,
              builder: (context) => ValueListenableBuilder<bool>(
                valueListenable: settings.postInfo,
                builder: (context, value, child) => SwitchListTile(
                  title: Text('Post info'),
                  subtitle: Text(value ? 'shown' : 'hidden'),
                  secondary: Icon(Icons.subtitles),
                  value: value,
                  onChanged: (value) => settings.postInfo.value = value,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: settings.fullscreen,
            builder: (context, value, child) => SwitchListTile(
              title: Text('Fullscreen'),
              subtitle: Text(value ? 'system ui hidden' : 'system ui shown'),
              secondary: Icon(value ? Icons.fullscreen : Icons.fullscreen_exit),
              value: value,
              onChanged: (value) => settings.fullscreen.value = value,
            ),
          ),
          Divider(),
          SettingsHeader(title: 'Beta'),
          ValueListenableBuilder<bool>(
            valueListenable: settings.beta,
            builder: (context, value, child) => SwitchListTile(
              title: Text('Experimental features'),
              subtitle: Text(value ? 'preview enabled' : 'preview disabled'),
              secondary: Icon(Icons.auto_awesome),
              value: value,
              onChanged: (value) {
                settings.beta.value = value;
                if (!value) {
                  settings.postInfo.value = false;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
