import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final Map<IconData, List<String>> hostIcons = {
  FontAwesomeIcons.mastodon: ['mastodon.art', 'baraag.net', 'aryion.com'],
  FontAwesomeIcons.discord: ['discord.com', 'cdn.discordapp.com'],
  FontAwesomeIcons.tumblr: ['media.tumblr.com', 'tumblr.com'],
  FontAwesomeIcons.vk: ['pp.userapi.com', 'vk.me'],
  FontAwesomeIcons.wikipediaW: ['upload.wikimedia.org'],
  FontAwesomeIcons.patreon: ['patreon.com'],
  FontAwesomeIcons.dropbox: ['dl.dropboxusercontent.com'],
  FontAwesomeIcons.facebookF: ['.fbcdn.net'],
  FontAwesomeIcons.twitter: ['.twimg.com', 'twitter.com'],
  FontAwesomeIcons.redditAlien: ['reddit.com'],
  FontAwesomeIcons.deviantart: ['.deviantart.com', '.deviantart.net'],
  FontAwesomeIcons.paw: ['furaffinity.net'],
  FontAwesomeIcons.p: ['pixiv.net', 'i.pximg.net'],
  FontAwesomeIcons.splotch: ['inkbunny.net', 'nl.ib.metapix.net'],
};

IconData? getHostIcon(String url) {
  Uri? uri = Uri.tryParse(url);
  if (uri != null) {
    for (final entry in hostIcons.entries) {
      for (final host in entry.value) {
        if (uri.host.contains(host)) {
          return entry.key;
        }
      }
    }
  }
  return null;
}
