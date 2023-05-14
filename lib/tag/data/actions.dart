import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

final List<String> wikiMetaTags =
    List.unmodifiable(['help:', 'e621:', 'howto:']);

String sortTags(String tags) => Tagset.parse(tags).toString();

/// Removes prefixes from tags.
String tagToRaw(String tags) => tags
    .trim()
    .split(' ')
    .map((tag) => tag.replaceAllMapped(RegExp(r'^[-~]'), (_) => ''))
    .join(' ');

/// Removes underscored from tags, adds commas.
String tagToName(String tags) =>
    tags.trim().split(' ').join(', ').replaceAll('_', ' ');

/// Removes underscores and prefixes from tags
String tagToTitle(String tags) => tagToName(tagToRaw(tags));

bool tagIsSingle(String tags) => !(tags.contains(' ') || tags.contains(':'));

enum TagCategory {
  general,
  species,
  character,
  copyright,
  meta,
  lore,
  artist,
  invalid;

  Color? get color {
    switch (this) {
      case general:
        return Colors.indigo[300];
      case species:
        return Colors.teal[300];
      case character:
        return Colors.lightGreen[300];
      case copyright:
        return Colors.yellow[300];
      case meta:
        return Colors.deepOrange[300];
      case lore:
        return Colors.pink[300];
      case artist:
        return Colors.deepPurple[300];
      case invalid:
      default:
        return Colors.grey[300];
    }
  }

  int get id {
    switch (this) {
      case general:
        return 0;
      case species:
        return 5;
      case character:
        return 4;
      case copyright:
        return 3;
      case meta:
        return 7;
      case lore:
        return 8;
      case artist:
        return 1;
      case invalid:
        return 6;
      default:
        return -1;
    }
  }

  static List<String> get names => values.asNameMap().keys.toList();

  static TagCategory byId(int id) => values.firstWhere((e) => e.id == id);

  static TagCategory byName(String name) =>
      values.asNameMap()[name.toLowerCase()]!;
}

List<String> filterArtists(List<String> artists) {
  List<String> excluded = [
    'epilepsy_warning',
    'conditional_dnp',
    'sound_warning',
    'avoid_posting',
  ];

  return List.from(artists)..removeWhere((artist) => excluded.contains(artist));
}
