import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'current.g.dart';

@JsonSerializable()
@CopyWith()
class CurrentUser {
  CurrentUser({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.id,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.baseUploadLimit,
    required this.postUploadCount,
    required this.postUpdateCount,
    required this.noteUpdateCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
    required this.avatarId,
    required this.showAvatars,
    required this.blacklistAvatars,
    required this.blacklistUsers,
    required this.descriptionCollapsedInitially,
    required this.hideComments,
    required this.showHiddenComments,
    required this.showPostStatistics,
    required this.hasMail,
    required this.receiveEmailNotifications,
    required this.enableKeyboardNavigation,
    required this.enablePrivacyMode,
    required this.styleUsernames,
    required this.enableAutoComplete,
    required this.hasSavedSearches,
    required this.disableCroppedThumbnails,
    required this.disableMobileGestures,
    required this.enableSafeMode,
    required this.disableResponsiveMode,
    required this.disablePostTooltips,
    required this.noFlagging,
    required this.noFeedback,
    required this.disableUserDmails,
    required this.enableCompactUploader,
    required this.updatedAt,
    required this.email,
    required this.lastLoggedInAt,
    required this.lastForumReadAt,
    required this.recentTags,
    required this.commentThreshold,
    required this.defaultImageSize,
    required this.favoriteTags,
    required this.blacklistedTags,
    required this.timeZone,
    required this.perPage,
    required this.customStyle,
    required this.favoriteCount,
    required this.apiRegenMultiplier,
    required this.apiBurstLimit,
    required this.remainingApiLimit,
    required this.statementTimeout,
    required this.favoriteLimit,
    required this.tagQueryLimit,
  });

  final int wikiPageVersionCount;
  final int artistVersionCount;
  final int poolVersionCount;
  final int forumPostCount;
  final int commentCount;
  final int flagCount;
  final int positiveFeedbackCount;
  final int neutralFeedbackCount;
  final int negativeFeedbackCount;
  final int uploadLimit;
  final int id;
  final DateTime createdAt;
  final String name;
  final int level;
  final int baseUploadLimit;
  final int postUploadCount;
  final int postUpdateCount;
  final int noteUpdateCount;
  final bool isBanned;
  final bool canApprovePosts;
  final bool canUploadFree;
  final String levelString;
  final int? avatarId;
  final bool showAvatars;
  final bool blacklistAvatars;
  final bool blacklistUsers;
  final bool descriptionCollapsedInitially;
  final bool hideComments;
  final bool showHiddenComments;
  final bool showPostStatistics;
  final bool hasMail;
  final bool receiveEmailNotifications;
  final bool enableKeyboardNavigation;
  final bool enablePrivacyMode;
  final bool styleUsernames;
  final bool enableAutoComplete;
  final bool hasSavedSearches;
  final bool disableCroppedThumbnails;
  final bool disableMobileGestures;
  final bool enableSafeMode;
  final bool disableResponsiveMode;
  final bool disablePostTooltips;
  final bool noFlagging;
  final bool noFeedback;
  final bool disableUserDmails;
  final bool enableCompactUploader;
  final DateTime updatedAt;
  final String email;
  final DateTime lastLoggedInAt;
  final DateTime? lastForumReadAt;
  final String? recentTags;
  final int commentThreshold;
  final String defaultImageSize;
  final String? favoriteTags;
  final String blacklistedTags;
  final String timeZone;
  final int perPage;
  final String? customStyle;
  final int favoriteCount;
  final int apiRegenMultiplier;
  final int apiBurstLimit;
  final int remainingApiLimit;
  final int statementTimeout;
  final int favoriteLimit;
  final int tagQueryLimit;

  factory CurrentUser.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserToJson(this);
}
