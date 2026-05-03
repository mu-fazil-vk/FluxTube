import 'package:flutter/material.dart';
import 'package:fluxtube/widgets/thumbnail_image.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:intl/intl.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({
    super.key,
    required this.playlistId,
    required this.title,
    required this.thumbnail,
    required this.videoCount,
    required this.uploaderName,
    this.uploaderAvatar,
    this.description,
    this.onTap,
  });

  final String playlistId;
  final String? title;
  final String? thumbnail;
  final int? videoCount;
  final String? uploaderName;
  final String? uploaderAvatar;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with video count overlay
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: kGreyColor,
                    borderRadius: BorderRadius.circular(20),
                    image: thumbnail != null
                        ? DecorationImage(
                            image: cachedThumbnailProvider(thumbnail!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                ),
                // Video count badge on right side
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: kBlackColor.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.playlist_play,
                          color: kWhiteColor,
                          size: 32,
                        ),
                        kHeightBox5,
                        Text(
                          '${_formatVideoCount(videoCount)} videos',
                          style: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            kHeightBox10,
            // Playlist info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title ?? 'Unknown Playlist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  kHeightBox5,
                  // Uploader info
                  Row(
                    children: [
                      if (uploaderAvatar != null) ...[
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: cachedAvatarProvider(uploaderAvatar!, logicalDiameter: 24),
                          backgroundColor: kGreyColor,
                        ),
                        kWidthBox10,
                      ],
                      Expanded(
                        child: Text(
                          uploaderName ?? 'Unknown',
                          style: TextStyle(
                            color: kGreyColor,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Playlist indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? kWhiteColor.withValues(alpha: 0.1)
                              : kGreyOpacityColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.playlist_play,
                              size: 16,
                              color: isDarkMode ? kWhiteColor : kBlackColor,
                            ),
                            kWidthBox5,
                            Text(
                              'Playlist',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? kWhiteColor : kBlackColor,
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
      ),
    );
  }

  String _formatVideoCount(int? count) {
    if (count == null) return '0';
    if (count >= 1000) {
      return NumberFormat.compact().format(count);
    }
    return count.toString();
  }
}

// Compact playlist widget for horizontal lists
class CompactPlaylistWidget extends StatelessWidget {
  const CompactPlaylistWidget({
    super.key,
    required this.playlistId,
    required this.title,
    required this.thumbnail,
    required this.videoCount,
    this.onTap,
  });

  final String playlistId;
  final String? title;
  final String? thumbnail;
  final int? videoCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kGreyColor,
                    borderRadius: BorderRadius.circular(12),
                    image: thumbnail != null
                        ? DecorationImage(
                            image: cachedThumbnailProvider(thumbnail!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kBlackColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.playlist_play,
                          color: kWhiteColor,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$videoCount',
                          style: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            kHeightBox5,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title ?? 'Unknown Playlist',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
