/// This should be replaced by a FilterList.
/// To do that, we need to upgrade FilterList to support required fields.
// TODO: Replace this with a FilterList
library;

enum PostReportType {
  rating,
  file,
  source,
  description,
  note,
  tagging;

  int get id => switch (this) {
    rating => 6,
    file => 5,
    source => 4,
    description => 3,
    note => 2,
    tagging => 1,
  };

  String get title => switch (this) {
    rating => 'Rating Abuse',
    file => 'Malicious File',
    source => 'Malicious Source',
    description => 'Description Abuse',
    note => 'Note Abuse',
    tagging => 'Tagging Abuse',
  };

  String get body => switch (this) {
    rating =>
      'A post is rated as incorretly, such as Rating Safe when it contains Explicit content.',
    file =>
      'Files that either contain malicious code, or contain other files attached to them.',
    source => 'Sources that link to malicious pages.',
    description =>
      'The description is used to harass someone, or if a valid description is being vandalized.',
    note =>
      'Notes in languages that aren\'t in english, or insult users, or are completely unrelated to the image itself.',
    tagging =>
      'Adding wrong tags, removing valid tags, creating insulting tags are all reasons to report a post for tagging abuse.',
  };
}
