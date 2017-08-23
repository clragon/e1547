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

import 'pagination.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.object == null) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    } else {
      print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object}');
    }
  });

  test('Load page 0 and 2', () async {
    Pagination<String> p = new Pagination<String>(3, (i) async {
      return new List.filled(3, i.toString());
    });

    expect(await p.loadPage(0), equals(3));
    expect(p.elements, equals(['0', '0', '0']));
    expect(await p.loadPage(2), equals(3));
    expect(
        p.elements, equals(['0', '0', '0', null, null, null, '2', '2', '2']));
  });
}
