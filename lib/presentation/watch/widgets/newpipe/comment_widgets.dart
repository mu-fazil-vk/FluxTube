import 'package:flutter/cupertino.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/watch/watch_bloc.dart';
import 'package:fluxtube/core/animations/animations.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/operations/math_operations.dart';
import 'package:fluxtube/core/player/global_player_controller.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_comments_resp.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NewPipeCommentSection extends StatefulWidget {
  const NewPipeCommentSection({
    super.key,
    required this.state,
    required this.height,
    required this.locals,
    required this.videoId,
  });

  final WatchState state;
  final double height;
  final S locals;
  final String videoId;

  @override
  State<NewPipeCommentSection> createState() => _NewPipeCommentSectionState();
}

class _NewPipeCommentSectionState extends State<NewPipeCommentSection> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<WatchBloc>().state;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.fetchMoreNewPipeCommentsStatus != ApiStatus.loading &&
        !state.isMoreNewPipeCommentsFetchCompleted &&
        state.newPipeComments.nextPage != null) {
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.getMoreNewPipeComments(
          id: widget.videoId,
          nextPage: state.newPipeComments.nextPage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: widget.height * 0.55),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(theme, isDark),
            // Comments list
            Flexible(
              child: BlocBuilder<WatchBloc, WatchState>(
                buildWhen: (previous, current) =>
                    previous.fetchNewPipeCommentsStatus != current.fetchNewPipeCommentsStatus ||
                    previous.fetchMoreNewPipeCommentsStatus != current.fetchMoreNewPipeCommentsStatus ||
                    previous.newPipeComments != current.newPipeComments ||
                    previous.isMoreNewPipeCommentsFetchCompleted != current.isMoreNewPipeCommentsFetchCompleted,
                builder: (context, state) {
                  return _buildCommentsList(theme, isDark, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    // Use the actual comment count from API, not the loaded comments length
    final commentCount = widget.state.newPipeComments.commentCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2_fill,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.locals.hideComments.replaceAll('Hide ', ''),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (commentCount > 0)
                  Text(
                    '${formatCount(commentCount.toString())} comments',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Disabled badge if applicable
          if (widget.state.newPipeComments.isDisabled == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Disabled',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme, bool isDark, WatchState state) {
    if (state.fetchNewPipeCommentsStatus == ApiStatus.initial ||
        state.fetchNewPipeCommentsStatus == ApiStatus.loading) {
      return const _ModernCommentShimmer();
    }

    if (state.fetchNewPipeCommentsStatus == ApiStatus.error) {
      return _buildErrorState(theme, isDark);
    }

    if (state.newPipeComments.isDisabled == true) {
      return _buildDisabledState(theme, isDark);
    }

    if (state.newPipeComments.comments?.isEmpty == true) {
      return _buildEmptyState(theme, isDark);
    }

    final comments = state.newPipeComments.comments ?? [];
    final hasMore = !state.isMoreNewPipeCommentsFetchCompleted &&
        state.newPipeComments.nextPage != null;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: comments.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < comments.length) {
          final comment = comments[index];
          return _ModernCommentCard(
            comment: comment,
            index: index,
            locals: widget.locals,
            videoId: widget.videoId,
            onReplyTap: comment.replyCount != null &&
                    comment.replyCount! > 0 &&
                    comment.repliesPage != null
                ? () => _showRepliesSheet(context, comment)
                : null,
            onProfileTap: () {
              final channelId = _extractChannelId(comment.authorUrl);
              if (channelId != null) {
                // Enable PIP before navigating to channel
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.togglePip(value: true));
                context.pushNamed('channel', pathParameters: {
                  'channelId': channelId,
                }, queryParameters: {
                  'avatarUrl': comment.authorAvatarUrl,
                });
              }
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: cIndicator(context),
          );
        }
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load comments',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                BlocProvider.of<WatchBloc>(context)
                    .add(WatchEvent.getNewPipeComments(id: widget.videoId));
              },
              icon: const Icon(CupertinoIcons.refresh, size: 16),
              label: Text(widget.locals.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.nosign,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.locals.commentsDisabled,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The creator has disabled comments for this video',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.chat_bubble,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.locals.noCommentsFound,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comments are disabled or unavailable for this video',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRepliesSheet(BuildContext context, NewPipeComment comment) {
    BlocProvider.of<WatchBloc>(context).add(
      WatchEvent.getNewPipeCommentReplies(
        videoId: widget.videoId,
        repliesPage: comment.repliesPage!,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernRepliesSheet(
        parentComment: comment,
        locals: widget.locals,
        videoId: widget.videoId,
      ),
    );
  }
}

// =============================================================================
// MODERN COMMENT CARD
// =============================================================================

class _ModernCommentCard extends StatelessWidget {
  const _ModernCommentCard({
    required this.comment,
    required this.index,
    required this.locals,
    required this.videoId,
    this.onReplyTap,
    this.onProfileTap,
    this.isReply = false,
  });

  final NewPipeComment comment;
  final int index;
  final S locals;
  final String videoId;
  final VoidCallback? onReplyTap;
  final VoidCallback? onProfileTap;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedListItem(
      index: index,
      child: Container(
        margin: EdgeInsets.only(
          left: isReply ? 48 : 16,
          right: 16,
          bottom: 4,
          top: 4,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark.withValues(alpha: 0.3)
              : AppColors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Avatar + Author info + Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isReply ? 14 : 18,
                      backgroundColor: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                      child: ClipOval(
                        child: comment.authorAvatarUrl != null &&
                                comment.authorAvatarUrl!.isNotEmpty
                            ? ThumbnailImage.small(
                                url: comment.authorAvatarUrl!,
                                width: isReply ? 28 : 36,
                                height: isReply ? 28 : 36,
                                errorWidget: (_, __, ___) => Icon(
                                  CupertinoIcons.person_fill,
                                  size: isReply ? 14 : 18,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              )
                            : Icon(
                                CupertinoIcons.person_fill,
                                size: isReply ? 14 : 18,
                                color: AppColors.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Author info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name row with badges
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Author name
                          Text(
                            comment.authorName ?? locals.commentAuthorNotFound,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isReply ? 12 : 13,
                            ),
                          ),
                          // Verified badge
                          if (comment.authorVerified == true)
                            Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              size: isReply ? 12 : 14,
                              color: AppColors.primary,
                            ),
                          // Commented time
                          if (comment.uploadDate != null &&
                              comment.uploadDate!.isNotEmpty)
                            Text(
                              comment.uploadDate!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.disabled,
                                fontSize: isReply ? 10 : 11,
                              ),
                            ),
                          // Author hearted badge - NEXT TO NAME
                          if (comment.isHearted == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.pink.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.heart_fill,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Liked',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Pinned badge
                          if (comment.isPinned == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.pin_fill,
                                    size: 10,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    locals.pinned,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Comment text
            _CommentTextWidget(
              text: comment.text ?? '',
              locals: locals,
              isReply: isReply,
            ),
            const SizedBox(height: 12),
            // Actions row
            Row(
              children: [
                // Like count
                _ActionChip(
                  icon: CupertinoIcons.hand_thumbsup_fill,
                  label: formatCount((comment.likeCount ?? 0).toString()),
                  isDark: isDark,
                ),
                // Reply button
                if (onReplyTap != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.arrowshape_turn_up_left_fill,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${formatCount((comment.replyCount ?? 0).toString())} ${locals.repliesPlural(comment.replyCount ?? 0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMMENT TEXT WITH CLICKABLE TIMESTAMPS AND LINKS
// =============================================================================

class _CommentTextWidget extends StatefulWidget {
  const _CommentTextWidget({
    required this.text,
    required this.locals,
    this.isReply = false,
  });

  final String text;
  final S locals;
  final bool isReply;

  @override
  State<_CommentTextWidget> createState() => _CommentTextWidgetState();
}

class _CommentTextWidgetState extends State<_CommentTextWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textSpan = _parseCommentText(context, widget.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          textSpan,
          maxLines: _isExpanded ? null : 4,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (_shouldShowReadMore())
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _isExpanded ? widget.locals.showLessText : widget.locals.readMoreText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _shouldShowReadMore() {
    // Simple heuristic: show read more if text is longer than ~200 chars or has many newlines
    return widget.text.length > 200 || widget.text.split('\n').length > 4;
  }

  TextSpan _parseCommentText(BuildContext context, String htmlText) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
          fontSize: widget.isReply ? 13 : 14,
          height: 1.4,
          color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        ) ??
        TextStyle(
          fontSize: widget.isReply ? 13 : 14,
          height: 1.4,
        );

    final linkStyle = defaultStyle.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );

    // Remove HTML tags
    String plainText = htmlText
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    plainText = plainText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    // Regex patterns
    final timestampPattern = RegExp(r'\b(\d{1,2}:)?(\d{1,2}):(\d{2})\b');
    final urlPattern = RegExp(r'https?://[^\s<>\[\]]+', caseSensitive: false);

    // Extract links from HTML href attributes
    final hrefPattern = RegExp(r'href="([^"]+)"[^>]*>([^<]+)</a>');
    final Map<String, String> linkMap = {};
    for (final match in hrefPattern.allMatches(htmlText)) {
      final url = match.group(1);
      final linkText = match.group(2);
      if (url != null && linkText != null) {
        linkMap[linkText] = url;
      }
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    final matches = <_MatchInfo>[];

    for (final match in timestampPattern.allMatches(plainText)) {
      matches.add(_MatchInfo(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: _MatchType.timestamp,
      ));
    }

    for (final match in urlPattern.allMatches(plainText)) {
      matches.add(_MatchInfo(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: _MatchType.url,
        url: match.group(0),
      ));
    }

    for (final entry in linkMap.entries) {
      final linkText = entry.key;
      final url = entry.value;
      int searchStart = 0;
      while (true) {
        final index = plainText.indexOf(linkText, searchStart);
        if (index == -1) break;

        final overlaps = matches.any((m) =>
            (index >= m.start && index < m.end) ||
            (index + linkText.length > m.start &&
                index + linkText.length <= m.end));

        if (!overlaps) {
          matches.add(_MatchInfo(
            start: index,
            end: index + linkText.length,
            text: linkText,
            type: _MatchType.url,
            url: url,
          ));
        }
        searchStart = index + linkText.length;
      }
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    final nonOverlapping = <_MatchInfo>[];
    for (final match in matches) {
      if (nonOverlapping.isEmpty || match.start >= nonOverlapping.last.end) {
        nonOverlapping.add(match);
      }
    }

    for (final match in nonOverlapping) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: plainText.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }

      spans.add(TextSpan(
        text: match.text,
        style: linkStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (match.type == _MatchType.timestamp) {
              _onTimestampTap(match.text);
            } else {
              _onUrlTap(match.url ?? match.text);
            }
          },
      ));

      lastEnd = match.end;
    }

    if (lastEnd < plainText.length) {
      spans.add(TextSpan(
        text: plainText.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return TextSpan(
      children: spans.isEmpty
          ? [TextSpan(text: plainText, style: defaultStyle)]
          : spans,
    );
  }

  void _onTimestampTap(String timestamp) {
    final parts =
        timestamp.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    int seconds = 0;
    if (parts.length == 3) {
      seconds = parts[0] * 3600 + parts[1] * 60 + parts[2];
    } else if (parts.length == 2) {
      seconds = parts[0] * 60 + parts[1];
    }
    GlobalPlayerController().player.seek(Duration(seconds: seconds));
  }

  void _onUrlTap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}

// =============================================================================
// MODERN REPLIES BOTTOM SHEET
// =============================================================================

class _ModernRepliesSheet extends StatefulWidget {
  const _ModernRepliesSheet({
    required this.parentComment,
    required this.locals,
    required this.videoId,
  });

  final NewPipeComment parentComment;
  final S locals;
  final String videoId;

  @override
  State<_ModernRepliesSheet> createState() => _ModernRepliesSheetState();
}

class _ModernRepliesSheetState extends State<_ModernRepliesSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<WatchBloc>().state;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.fetchMoreNewPipeCommentRepliesStatus != ApiStatus.loading &&
        !state.isMoreNewPipeReplyCommentsFetchCompleted &&
        state.newPipeCommentReplies.nextPage != null) {
      BlocProvider.of<WatchBloc>(context).add(
        WatchEvent.getMoreNewPipeCommentReplies(
          videoId: widget.videoId,
          nextPage: state.newPipeCommentReplies.nextPage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            _buildSheetHeader(theme, isDark),
            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
            // Replies list
            Expanded(
              child: BlocBuilder<WatchBloc, WatchState>(
                buildWhen: (previous, current) =>
                    previous.fetchNewPipeCommentRepliesStatus !=
                        current.fetchNewPipeCommentRepliesStatus ||
                    previous.fetchMoreNewPipeCommentRepliesStatus !=
                        current.fetchMoreNewPipeCommentRepliesStatus ||
                    previous.newPipeCommentReplies != current.newPipeCommentReplies,
                builder: (context, state) {
                  if (state.fetchNewPipeCommentRepliesStatus == ApiStatus.loading ||
                      state.fetchNewPipeCommentRepliesStatus == ApiStatus.initial) {
                    return const _ModernCommentShimmer();
                  }

                  if (state.fetchNewPipeCommentRepliesStatus == ApiStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 40,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: () {
                              context.read<WatchBloc>().add(
                                    WatchEvent.getNewPipeCommentReplies(
                                      videoId: widget.videoId,
                                      repliesPage: widget.parentComment.repliesPage!,
                                    ),
                                  );
                            },
                            child: Text(widget.locals.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  final replies = state.newPipeCommentReplies.comments ?? [];
                  final isLoadingMore =
                      state.fetchMoreNewPipeCommentRepliesStatus == ApiStatus.loading;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: replies.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < replies.length) {
                        final reply = replies[index];
                        return _ModernCommentCard(
                          comment: reply,
                          index: index,
                          locals: widget.locals,
                          videoId: widget.videoId,
                          isReply: true,
                          onProfileTap: () {
                            final channelId = _extractChannelId(reply.authorUrl);
                            if (channelId != null) {
                              // Enable PIP before navigating to channel
                              BlocProvider.of<WatchBloc>(context)
                                  .add(WatchEvent.togglePip(value: true));
                              Navigator.pop(context);
                              context.pushNamed('channel', pathParameters: {
                                'channelId': channelId,
                              }, queryParameters: {
                                'avatarUrl': reply.authorAvatarUrl,
                              });
                            }
                          },
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: cIndicator(context),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.arrowshape_turn_up_left_fill,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${formatCount((widget.parentComment.replyCount ?? 0).toString())} ${widget.locals.repliesPlural(widget.parentComment.replyCount ?? 0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
            ),
            icon: Icon(
              CupertinoIcons.xmark,
              size: 18,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODERN SHIMMER
// =============================================================================

class _ModernCommentShimmer extends StatelessWidget {
  const _ModernCommentShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (index) => _ShimmerCard(isDark: isDark, index: index),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({required this.isDark, required this.index});

  final bool isDark;
  final int index;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariant;
    final highlightColor = widget.isDark
        ? AppColors.surfaceVariantDark.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar shimmer
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: [baseColor, highlightColor, baseColor],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name shimmer
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: [baseColor, highlightColor, baseColor],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Text shimmer
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: [baseColor, highlightColor, baseColor],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment(_animation.value - 1, 0),
                          end: Alignment(_animation.value, 0),
                          colors: [baseColor, highlightColor, baseColor],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// HELPER CLASSES
// =============================================================================

enum _MatchType { timestamp, url }

class _MatchInfo {
  final int start;
  final int end;
  final String text;
  final _MatchType type;
  final String? url;

  _MatchInfo({
    required this.start,
    required this.end,
    required this.text,
    required this.type,
    this.url,
  });
}

String? _extractChannelId(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    final channelIndex = uri.pathSegments.indexOf('channel');
    if (channelIndex != -1 && channelIndex + 1 < uri.pathSegments.length) {
      return uri.pathSegments[channelIndex + 1];
    }
  }
  return null;
}
