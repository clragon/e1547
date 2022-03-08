import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

final List<String> wikiMetaTags = List.unmodifiable(['help:', 'e621:']);

String sortTags(String tags) {
  return Tagset.parse(tags).toString();
}

String tagToName(String tags) => tags
    .trim()
    .split(' ')
    .map((tag) => tag.replaceAllMapped(RegExp(r'^[-~]'), (_) => ''))
    .join(' ');

String tagToTitle(String tags) =>
    tags.replaceAll(',', ' ').split(' ').trim().join(', ').replaceAll('_', ' ');

String tagToCard(String tags) => tagToTitle(tagToName(tags));

Color? getCategoryColor(String category) {
  switch (category) {
    case 'general':
      return Colors.indigo[300];
    case 'species':
      return Colors.teal[300];
    case 'character':
      return Colors.lightGreen[300];
    case 'copyright':
      return Colors.yellow[300];
    case 'meta':
      return Colors.deepOrange[300];
    case 'lore':
      return Colors.pink[300];
    case 'artist':
      return Colors.deepPurple[300];
    default:
      return Colors.grey[300];
  }
}

Map<String, int> categories = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'meta': 7,
  'lore': 8,
  'artist': 1,
  'invalid': 6,
};

List<String> filterArtists(List<String> artists) {
  List<String> excluded = [
    'epilepsy_warning',
    'conditional_dnp',
    'sound_warning',
    'avoid_posting',
  ];

  return List.from(artists)..removeWhere((artist) => excluded.contains(artist));
}
