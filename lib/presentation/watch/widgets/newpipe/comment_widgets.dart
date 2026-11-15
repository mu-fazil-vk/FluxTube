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
    final scheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(maxHeight: widget.height * 0.55),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, isDark),
          Flexible(
            child: BlocBuilder<WatchBloc, WatchState>(
              buildWhen: (previous, current) =>
                  previous.fetchNewPipeCommentsStatus !=
                      current.fetchNewPipeCommentsStatus ||
                  previous.fetchMoreNewPipeCommentsStatus !=
                      current.fetchMoreNewPipeCommentsStatus ||
                  previous.newPipeComments != current.newPipeComments ||
                  previous.isMoreNewPipeCommentsFetchCompleted !=
                      current.isMoreNewPipeCommentsFetchCompleted,
              builder: (context, state) {
                return _buildCommentsList(theme, isDark, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final scheme = theme.colorScheme;
    final commentCount = widget.state.newPipeComments.commentCount ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            widget.locals.comments,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (commentCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              formatCount(commentCount.toString()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: 8),
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
    return _CommentsStatusView(
      icon: CupertinoIcons.wifi_exclamationmark,
      title: widget.locals.commentsLoadFailed,
      subtitle: widget.locals.checkConnectionAndRetry,
      action: FilledButton.tonalIcon(
        onPressed: () {
          BlocProvider.of<WatchBloc>(context)
              .add(WatchEvent.getNewPipeComments(id: widget.videoId));
        },
        icon: const Icon(CupertinoIcons.refresh, size: 16),
        label: Text(widget.locals.retry),
      ),
    );
  }

  Widget _buildDisabledState(ThemeData theme, bool isDark) {
    return _CommentsStatusView(
      icon: CupertinoIcons.chat_bubble_2,
      title: widget.locals.commentsDisabled,
      subtitle: widget.locals.commentsDisabledByCreator,
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return _CommentsStatusView(
      icon: CupertinoIcons.chat_bubble,
      title: widget.locals.noCommentsFound,
      subtitle: widget.locals.noCommentsYet,
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
    final scheme = theme.colorScheme;
    final avatarSize = isReply ? 28.0 : 36.0;
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 12,
    );
    final likeCount = comment.likeCount ?? 0;
    final replyCount = comment.replyCount ?? 0;

    return AnimatedListItem(
      index: index,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isReply ? 24 : 16, 10, 16, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: ClipOval(
                child: SizedBox.square(
                  dimension: avatarSize,
                  child: ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: comment.authorAvatarUrl != null &&
                            comment.authorAvatarUrl!.isNotEmpty
                        ? ThumbnailImage.small(
                            url: comment.authorAvatarUrl!,
                            width: avatarSize,
                            height: avatarSize,
                            errorWidget: (_, __, ___) => Icon(
                              CupertinoIcons.person_fill,
                              size: avatarSize / 2,
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            CupertinoIcons.person_fill,
                            size: avatarSize / 2,
                            color: scheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (comment.isPinned == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pin_fill,
                              size: 11, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(locals.pinned, style: metaStyle),
                        ],
                      ),
                    ),
                  // "@author · 2 days ago"
                  Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: onProfileTap,
                          child: Text(
                            comment.authorName ?? locals.commentAuthorNotFound,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: metaStyle?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (comment.authorVerified == true) ...[
                        const SizedBox(width: 3),
                        Icon(CupertinoIcons.checkmark_seal_fill,
                            size: 12, color: scheme.onSurfaceVariant),
                      ],
                      // YouTube already appends "(edited)" to this text.
                      if (comment.uploadDate != null &&
                          comment.uploadDate!.isNotEmpty)
                        Flexible(
                          child: Text(
                            '  ·  ${comment.uploadDate!}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: metaStyle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _CommentTextWidget(
                    text: comment.text ?? '',
                    locals: locals,
                    isReply: isReply,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(CupertinoIcons.hand_thumbsup,
                          size: 15, color: scheme.onSurfaceVariant),
                      if (likeCount > 0) ...[
                        const SizedBox(width: 5),
                        Text(formatCount(likeCount.toString()),
                            style: metaStyle),
                      ],
                      if (comment.isHearted == true) ...[
                        const SizedBox(width: 16),
                        Tooltip(
                          message: locals.heartedByCreator,
                          child: const Icon(CupertinoIcons.heart_fill,
                              size: 14, color: Color(0xFFFF525E)),
                        ),
                      ],
                    ],
                  ),
                  if (onReplyTap != null && replyCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TextButton.icon(
                        onPressed: onReplyTap,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: scheme.primary,
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(CupertinoIcons.chevron_down, size: 14),
                        label: Text(
                          '${formatCount(replyCount.toString())} ${locals.repliesPlural(replyCount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsStatusView extends StatelessWidget {
  const _CommentsStatusView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
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
                _isExpanded
                    ? widget.locals.showLessText
                    : widget.locals.readMoreText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
          fontSize: widget.isReply ? 13 : 14,
          height: 1.4,
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: widget.isReply ? 13 : 14,
          height: 1.4,
        );

    final linkStyle = defaultStyle.copyWith(
      color: theme.colorScheme.primary,
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
        .replaceAll('&apos;', "'")
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
    GlobalPlayerController().seekTo(Duration(seconds: seconds));
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

    final scheme = theme.colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetHeader(theme, isDark),
            // The comment being replied to, for context.
            _ModernCommentCard(
              comment: widget.parentComment,
              index: 0,
              locals: widget.locals,
              videoId: widget.videoId,
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            // Replies list
            Expanded(
              child: BlocBuilder<WatchBloc, WatchState>(
                buildWhen: (previous, current) =>
                    previous.fetchNewPipeCommentRepliesStatus !=
                        current.fetchNewPipeCommentRepliesStatus ||
                    previous.fetchMoreNewPipeCommentRepliesStatus !=
                        current.fetchMoreNewPipeCommentRepliesStatus ||
                    previous.newPipeCommentReplies !=
                        current.newPipeCommentReplies,
                builder: (context, state) {
                  if (state.fetchNewPipeCommentRepliesStatus ==
                          ApiStatus.loading ||
                      state.fetchNewPipeCommentRepliesStatus ==
                          ApiStatus.initial) {
                    return const _ModernCommentShimmer();
                  }

                  if (state.fetchNewPipeCommentRepliesStatus ==
                      ApiStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 36,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: () {
                              context.read<WatchBloc>().add(
                                    WatchEvent.getNewPipeCommentReplies(
                                      videoId: widget.videoId,
                                      repliesPage:
                                          widget.parentComment.repliesPage!,
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
                      state.fetchMoreNewPipeCommentRepliesStatus ==
                          ApiStatus.loading;

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
                            final channelId =
                                _extractChannelId(reply.authorUrl);
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
    final scheme = theme.colorScheme;
    final count = widget.parentComment.replyCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.locals.repliesPlural(2),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Text(
              formatCount(count.toString()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(CupertinoIcons.xmark,
                size: 20, color: scheme.onSurfaceVariant),
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
    final baseColor =
        widget.isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
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
