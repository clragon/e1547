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

  // Get the URL for the HTML version of the desired post.
  Uri url(String host) =>
      new Uri(scheme: 'https', host: host, path: '/post/show/$id');

  int id;
  String author;
  int score;
  int favCount;
  String fileUrl;
  String fileExt;
  String previewUrl;
  int previewWidth;
  int previewHeight;
  String sampleUrl;
  int sampleWidth;
  int sampleHeight;
  String rating;
  bool hasComments;
  List<String> artist;

  Post.fromRaw(Map raw) {
    this.raw = raw;

    id = raw['id'];
    author = raw['author'];
    score = raw['score'];
    favCount = raw['fav_count'];
    fileUrl = raw['file_url'];
    fileExt = raw['file_ext'];
    previewUrl = raw['preview_url'];
    previewWidth = raw['preview_width'];
    previewHeight = raw['preview_height'];
    sampleUrl = raw['sample_url'];
    sampleWidth = raw['sample_width'];
    sampleHeight = raw['sample_height'];

    rating = raw['rating'].toUpperCase();

    hasComments = raw['has_comments'];

    artist = raw['artist'];
  }
}
