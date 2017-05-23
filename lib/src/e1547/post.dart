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

class Post {
  Map raw;
  String _host;

  // Get the URL for the HTML version of the desired post.
  Uri get url => new Uri(scheme: 'https', host: _host, path: '/post/show/$id');

  int id;
  int score;
  int fav_count;
  String file_url;
  String file_ext;
  String sample_url;
  int sample_width;
  int sample_height;
  String rating;
  List<String> artist;

  Post.fromRaw(Map raw, String host) {
    this.raw = raw;
    this._host = host;

    id = raw['id'];
    score = raw['score'];
    fav_count = raw['fav_count'];
    file_url = raw['file_url'];
    file_ext = raw['file_ext'];
    sample_url = raw['sample_url'];
    sample_width = raw['sample_width'];
    sample_height = raw['sample_height'];

    rating = raw['rating'].toUpperCase();

    artist = raw['artist'];
  }
}
