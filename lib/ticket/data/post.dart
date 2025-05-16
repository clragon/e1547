/// This should be replaced by a FilterList.
/// To do that, we need to upgrade FilterList to support required fields.
// TODO: Replace this with a FilterList
library;

enum ReportType {
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
      'A post is rated as safe when it is not, or if a post is rated as explicit when it is not.',
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

enum FlagType {
  dnpArtist,
  payContent,
  trace,
  previouslyDeleted,
  realPorn,
  corrupt,
  inferior;

  String get id => switch (this) {
    dnpArtist => 'dnp_artist',
    payContent => 'pay_content',
    trace => 'trace',
    previouslyDeleted => 'previously_deleted',
    realPorn => 'real_porn',
    corrupt => 'corrupt',
    inferior => 'inferior',
  };

  String get title => switch (this) {
    dnpArtist => 'The artist of is on the avoid posting list',
    payContent => 'Paysite, commercial, or subscription content',
    trace => "Trace of another artist's work",
    previouslyDeleted => 'Previously deleted',
    realPorn => 'Real-life pornography',
    corrupt => 'File is either corrupted, broken, or otherwise does not work',
    inferior => 'Duplicate or inferior version of another post',
  };

  String get body => switch (this) {
    dnpArtist =>
      'Certain artists have requested that their work is not to be published on this site, and were granted [[avoid_posting|Do Not Post]] status.\nSometimes, that status comes with conditions; see [[conditional_dnp]] for more information',
    payContent =>
      'We do not host paysite or commercial content of any kind. This includes Patreon leaks, reposts from piracy websites, and so on.',
    trace =>
      "Images traced from other artists' artwork are not accepted on this site. Referencing from something is fine, but outright copying someone else's work is not.\nPlease, leave more information in the comments, or simply add the original artwork as the posts's parent if it's hosted on this site.",
    previouslyDeleted =>
      "Posts usually get removed for a good reason, and reuploading of deleted content is not acceptable.\nPlease, leave more information in the comments, or simply add the original post as this post's parent.",
    realPorn =>
      'Posts featuring real-life pornography are not acceptable on this site. No exceptions.\nNote that images featuring non-erotic photographs are acceptable.',
    corrupt =>
      'Something about this post does not work quite right. This may be a broken video, or a corrupted image.\nEither way, in order to avoid confusion, please explain the situation in the comments.',
    inferior =>
      'A superior version of this post already exists on the site.\nThis may include images with better visal quality (larger, less compressed), but may also feature "fixed" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.',
  };
}
