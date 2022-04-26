enum ReportType {
  rating,
  file,
  source,
  description,
  note,
  tagging,
}

const Map<ReportType, String> reportTypes = {
  ReportType.rating: "Rating Abuse",
  ReportType.file: "Malicious File",
  ReportType.source: "Malicious Source",
  ReportType.description: "Description Abuse",
  ReportType.note: "Note Abuse",
  ReportType.tagging: "Tagging Abuse",
};

const Map<ReportType, int> reportIds = {
  ReportType.rating: 6,
  ReportType.file: 5,
  ReportType.source: 4,
  ReportType.description: 3,
  ReportType.note: 2,
  ReportType.tagging: 1,
};

enum FlagType {
  dnpArtist,
  payContent,
  trace,
  previouslyDeleted,
  realPorn,
  corrupt,
  inferior,
}

const Map<FlagType, String> flagTypes = {
  FlagType.dnpArtist: "The artist of is on the avoid posting list",
  FlagType.payContent: "Paysite, commercial, or subscription content",
  FlagType.trace: "Trace of another artist's work",
  FlagType.previouslyDeleted: "Previously deleted",
  FlagType.realPorn: "Real-life pornography",
  FlagType.corrupt:
      "File is either corrupted, broken, or otherwise does not work",
  FlagType.inferior: "Duplicate or inferior version of another post",
};

const Map<FlagType, String> flagDescriptions = {
  FlagType.dnpArtist:
      "Certain artists have requested that their work is not to be published on this site, and were granted [[avoid_posting|Do Not Post]] status.\nSometimes, that status comes with conditions; see [[conditional_dnp]] for more information",
  FlagType.payContent:
      "We do not host paysite or commercial content of any kind. This includes Patreon leaks, reposts from piracy websites, and so on.",
  FlagType.trace:
      "Images traced from other artists' artwork are not accepted on this site. Referencing from something is fine, but outright copying someone else's work is not.\nPlease, leave more information in the comments, or simply add the original artwork as the posts's parent if it's hosted on this site.",
  FlagType.previouslyDeleted:
      "Posts usually get removed for a good reason, and reuploading of deleted content is not acceptable.\nPlease, leave more information in the comments, or simply add the original post as this post's parent.",
  FlagType.realPorn:
      "Posts featuring real-life pornography are not acceptable on this site. No exceptions.\nNote that images featuring non-erotic photographs are acceptable.",
  FlagType.corrupt:
      "Something about this post does not work quite right. This may be a broken video, or a corrupted image.\nEither way, in order to avoid confusion, please explain the situation in the comments.",
  FlagType.inferior:
      "A superior version of this post already exists on the site.\nThis may include images with better visual quality (larger, less compressed), but may also feature \"fixed\" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.",
};

const Map<FlagType, String> flagName = {
  FlagType.dnpArtist: 'dnp_artist',
  FlagType.payContent: 'pay_content',
  FlagType.trace: 'trace',
  FlagType.previouslyDeleted: 'previously_deleted',
  FlagType.realPorn: 'real_porn',
  FlagType.corrupt: 'corrupt',
  FlagType.inferior: 'inferior',
};
