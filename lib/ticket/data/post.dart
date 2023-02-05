enum ReportType {
  rating,
  file,
  source,
  description,
  note,
  tagging;

  int get id {
    switch (this) {
      case rating:
        return 6;
      case file:
        return 5;
      case source:
        return 4;
      case description:
        return 3;
      case note:
        return 2;
      case tagging:
        return 1;
      default:
        throw ArgumentError('Invalid ReportType when fetching id');
    }
  }

  String get title {
    switch (this) {
      case rating:
        return 'Rating Abuse';
      case file:
        return 'Malicious File';
      case source:
        return 'Malicious Source';
      case description:
        return 'Description Abuse';
      case note:
        return 'Note Abuse';
      case tagging:
        return 'Tagging Abuse';
      default:
        throw ArgumentError('Invalid ReportType when fetching title');
    }
  }
}

enum FlagType {
  dnpArtist,
  payContent,
  trace,
  previouslyDeleted,
  realPorn,
  corrupt,
  inferior;

  String get id {
    switch (this) {
      case dnpArtist:
        return 'dnp_artist';
      case payContent:
        return 'pay_content';
      case trace:
        return 'trace';
      case previouslyDeleted:
        return 'previously_deleted';
      case realPorn:
        return 'real_porn';
      case corrupt:
        return 'corrupt';
      case inferior:
        return 'inferior';
      default:
        throw ArgumentError('Invalid FlagType when fetching id');
    }
  }

  String get title {
    switch (this) {
      case dnpArtist:
        return 'The artist of is on the avoid posting list';
      case payContent:
        return 'Paysite, commercial, or subscription content';
      case trace:
        return "Trace of another artist's work";
      case previouslyDeleted:
        return 'Previously deleted';
      case realPorn:
        return 'Real-life pornography';
      case corrupt:
        return 'File is either corrupted, broken, or otherwise does not work';
      case inferior:
        return 'Duplicate or inferior version of another post';
      default:
        throw ArgumentError('Invalid FlagType when fetching title');
    }
  }

  String get description {
    switch (this) {
      case dnpArtist:
        return 'Certain artists have requested that their work is not to be published on this site, and were granted [[avoid_posting|Do Not Post]] status.\nSometimes, that status comes with conditions; see [[conditional_dnp]] for more information';
      case payContent:
        return 'We do not host paysite or commercial content of any kind. This includes Patreon leaks, reposts from piracy websites, and so on.';
      case trace:
        return "Images traced from other artists' artwork are not accepted on this site. Referencing from something is fine, but outright copying someone else's work is not.\nPlease, leave more information in the comments, or simply add the original artwork as the posts's parent if it's hosted on this site.";
      case previouslyDeleted:
        return "Posts usually get removed for a good reason, and reuploading of deleted content is not acceptable.\nPlease, leave more information in the comments, or simply add the original post as this post's parent.";
      case realPorn:
        return 'Posts featuring real-life pornography are not acceptable on this site. No exceptions.\nNote that images featuring non-erotic photographs are acceptable.';
      case corrupt:
        return 'Something about this post does not work quite right. This may be a broken video, or a corrupted image.\nEither way, in order to avoid confusion, please explain the situation in the comments.';
      case inferior:
        return 'A superior version of this post already exists on the site.\nThis may include images with better visal quality (larger, less compressed), but may also feature "fixed" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.';
      default:
        throw ArgumentError('Invalid FlagType when fetching description');
    }
  }
}
