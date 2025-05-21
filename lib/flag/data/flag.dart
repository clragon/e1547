import 'package:freezed_annotation/freezed_annotation.dart';

part 'flag.freezed.dart';
part 'flag.g.dart';

@freezed
class PostFlag with _$PostFlag {
  const factory PostFlag({
    required int id,
    required DateTime createdAt,
    required int postId,
    required String reason,
    required int creatorId,
    required bool isResolved,
    required DateTime updatedAt,
    required bool isDeletion,
    required PostFlagType type,
  }) = _PostFlag;

  factory PostFlag.fromJson(Map<String, dynamic> json) =>
      _$PostFlagFromJson(json);
}

enum PostFlagType { flag, deletion }

enum FlagType {
  uploadingGuidelines,
  youngHuman,
  dnpArtist,
  payContent,
  trace,
  previouslyDeleted,
  realPorn,
  corrupt,
  inferior;

  String get id => switch (this) {
    uploadingGuidelines => 'uploading_guidelines',
    youngHuman => 'young_human',
    dnpArtist => 'dnp_artist',
    payContent => 'pay_content',
    trace => 'trace',
    previouslyDeleted => 'previously_deleted',
    realPorn => 'real_porn',
    corrupt => 'corrupt',
    inferior => 'inferior',
  };

  String get title => switch (this) {
    uploadingGuidelines =>
      'Does not meet the [[uploading_guidelines|uploading guidelines]]',
    youngHuman =>
      'Young [[human]]-[[humanoid|like]] character in an explicit situation',
    dnpArtist =>
      'The artist of this post is on the "avoid posting list":/static/avoid_posting',
    payContent => 'Paysite, commercial, or subscription content',
    trace => "Trace of another artist's work",
    previouslyDeleted => 'Previously deleted',
    realPorn => 'Real-life pornography',
    corrupt => 'File is either corrupted, broken, or otherwise does not work',
    inferior => 'Duplicate or inferior version of another post',
  };

  String get body => switch (this) {
    uploadingGuidelines =>
      "This post fails to meet the site's standards, be it for artistic worth, image quality, relevancy, or something else.\nKeep in mind that your personal preferences have no bearing on this. If you find the content of a post objectionable, simply [[e621:blacklist|blacklist]] it.",
    youngHuman =>
      'Posts featuring human and human-like characters depicted in a sexual or explicit nude way, are not acceptable on this site.',
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
      'A superior version of this post already exists on the site.\nThis may include images with better visual quality (larger, less compressed), but may also feature "fixed" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.',
  };
}
