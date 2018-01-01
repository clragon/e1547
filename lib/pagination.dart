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

/// A function that loads and returns pages of elements.
typedef Future<List<E>> PageLoader<E>(int pageNumber);

/// Models a paginated list of elements where pages may vary in size.
///
/// Index starts at 1, not 0.
class LinearPagination<T> {
  LinearPagination(this._loadPage);

  int _page = 1;
  bool _more = true;

  // List is unmodifiable, but the elements themselves are not.
  // This is just to prevent the size of the list from changing.
  // It may be desirable to modify, say, Post objects for editing
  // purposes.
  final List<T> _elements = [];
  List<T> get elements => new List.unmodifiable(_elements);

  final PageLoader<T> _loadPage;

  /// Load the next page. Returns false if there are no more pages to be
  /// loaded.
  Future<bool> loadNextPage() async {
    if (!_more) {
      return false;
    }

    List<T> newPage = await _loadPage(_page++);
    _elements.addAll(newPage);

    return _more = newPage.isNotEmpty;
  }
}
