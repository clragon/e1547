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
      for (Tag t in tset) {
        print(t);
      }
      expect(tset, contains(new Tag('kikurage')));
    });
  });
}
