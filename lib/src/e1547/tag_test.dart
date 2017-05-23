// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'tag.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.object == null) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    } else {
      print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object}');
    }
  });

  group('Tag:', () {
    test('Parse regular tag', () {
      Tag t = new Tag.parse('cute_fangs');
      expect(t.name, equals('cute_fangs'));
      expect(t.value, isNull);
    });

    test('Parse regular tag with whitespace', () {
      Tag t = new Tag.parse('	cute_fangs\n ');
      expect(t.name, equals('cute_fangs'));
    });

    test('Parse meta tag', () {
      Tag t = new Tag.parse('order:score');
      expect(t.name, equals('order'));
      expect(t.value, equals('score'));
    });

    test('Parse range meta tag', () {
      Tag t = new Tag.parse('score:>=20');
      expect(t.name, equals('score'));
      expect(t.value, equals('>=20'));
    });
  });

  group('Tagset:', () {
    test('Parse simple tagstring', () {
      Tagset tset = new Tagset.parse('kikurage cute_fangs');
      expect(tset, orderedEquals([new Tag('kikurage'), new Tag('cute_fangs')]));
    });

    test('Parse simple tagstring with whitespace', () {
      Tagset tset = new Tagset.parse('  kikurage \t \ncute_fangs\t \n');
      expect(tset, orderedEquals([new Tag('kikurage'), new Tag('cute_fangs')]));
    });;

    test('Check URL', () {
      Uri url = (new Tagset.parse('cute_fangs order:score')).url('e1547.io');
      Uri ans =
          Uri.parse('https://e1547.io/post?tags=cute_fangs+order%3Ascore');
      expect(url, equals(ans));
    });
  });
}
