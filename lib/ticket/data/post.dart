enum ReportType {
  Rating,
  File,
  Source,
  Description,
  Note,
  Tagging,
}

const Map<ReportType, String> reportTypes = {
  ReportType.Rating: "Rating Abuse",
  ReportType.File: "Malicious File",
  ReportType.Source: "Malicious Source",
  ReportType.Description: "Description Abuse",
  ReportType.Note: "Note Abuse",
  ReportType.Tagging: "Tagging Abuse",
};

const Map<ReportType, int> reportIds = {
  ReportType.Rating: 6,
  ReportType.File: 5,
  ReportType.Source: 4,
  ReportType.Description: 3,
  ReportType.Note: 2,
  ReportType.Tagging: 1,
};

enum FlagType {
  DnpArtist,
  PayContent,
  Trace,
  PreviouslyDeleted,
  RealPorn,
  Corrupt,
  Inferior,
}

const Map<FlagType, String> flagTypes = {
  FlagType.DnpArtist: "The artist of is on the avoid posting list",
  FlagType.PayContent: "Paysite, commercial, or subscription content",
  FlagType.Trace: "Trace of another artist's work",
  FlagType.PreviouslyDeleted: "Previously deleted",
  FlagType.RealPorn: "Real-life pornography",
  FlagType.Corrupt:
      "File is either corrupted, broken, or otherwise does not work",
  FlagType.Inferior: "Duplicate or inferior version of another post",
};

const Map<FlagType, String> flagDescriptions = {
  FlagType.DnpArtist:
      "Certain artists have requested that their work is not to be published on this site, and were granted [[avoid_posting|Do Not Post]] status.\nSometimes, that status comes with conditions; see [[conditional_dnp]] for more information",
  FlagType.PayContent:
      "We do not host paysite or commercial content of any kind. This includes Patreon leaks, reposts from piracy websites, and so on.",
  FlagType.Trace:
      "Images traced from other artists' artwork are not accepted on this site. Referencing from something is fine, but outright copying someone else's work is not.\nPlease, leave more information in the comments, or simply add the original artwork as the posts's parent if it's hosted on this site.",
  FlagType.PreviouslyDeleted:
      "Posts usually get removed for a good reason, and reuploading of deleted content is not acceptable.\nPlease, leave more information in the comments, or simply add the original post as this post's parent.",
  FlagType.RealPorn:
      "Posts featuring real-life pornography are not acceptable on this site. No exceptions.\nNote that images featuring non-erotic photographs are acceptable.",
  FlagType.Corrupt:
      "Something about this post does not work quite right. This may be a broken video, or a corrupted image.\nEither way, in order to avoid confusion, please explain the situation in the comments.",
  FlagType.Inferior:
      "A superior version of this post already exists on the site.\nThis may include images with better visual quality (larger, less compressed), but may also feature \"fixed\" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.",
};

const Map<FlagType, String> flagName = {
  FlagType.DnpArtist: 'dnp_artist',
  FlagType.PayContent: 'pay_content',
  FlagType.Trace: 'trace',
  FlagType.PreviouslyDeleted: 'previously_deleted',
  FlagType.RealPorn: 'real_porn',
  FlagType.Corrupt: 'corrupt',
  FlagType.Inferior: 'inferior',
};
