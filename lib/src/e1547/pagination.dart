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

import 'dart:async' show Future;
import 'dart:math' as math;

/// A function that loads and returns pages of elements.
typedef Future<List<E>> PageLoader<E>(int pageNumber);

/// Models a paginated list of elements.
///
/// All pages must have a number of elements equal to the page size,
/// except for the last page, which must have at least 1 element and no
/// more than the the page size.
class Pagination<T> {
  final int pageSize;
  final PageLoader<T> _loadPage;
  Pagination(this.pageSize, this._loadPage);

  // List is unmodifiable, but the elements themselves are not.
  // This is just to prevent the size of the list from changing.
  // It may be desirable to modify, say, Post objects for editing
  // purposes.
  List<T> _elements = [];
  List<T> get elements => new List.unmodifiable(_elements);

  /// Load the page at [index] and insert into [elements].
  ///
  /// Returns the number of elements that were loaded.
  /// TODO do we care about the number of elements, or just that it's
  /// the last page?
  Future<int> loadPage(int index) async {
    List<T> newPage = await _loadPage(index);
    if (newPage.isEmpty) {
      return 0;
    }

    // TODO test for overflow and growing the length of _elements
    // TODO test for clobbering elements in next page, too many
    // elements returned for a single page
    int start = index * pageSize;
    int end = start + newPage.length;

    _elements.length = math.max(_elements.length, end);
    _elements.replaceRange(start, end, newPage);

    return newPage.length;
  }
}

/*
class LinearPagination<T> extends Pagination<T> {
  LinearPagination(this.pagesize, this.loadPage);
}
*/
