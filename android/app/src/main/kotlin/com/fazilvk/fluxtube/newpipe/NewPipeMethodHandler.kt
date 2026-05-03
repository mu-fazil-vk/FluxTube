package com.fazilvk.fluxtube.newpipe

import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.schabi.newpipe.extractor.InfoItem
import org.schabi.newpipe.extractor.NewPipe
import org.schabi.newpipe.extractor.ServiceList
import org.schabi.newpipe.extractor.channel.ChannelInfo
import org.schabi.newpipe.extractor.comments.CommentsInfo
import org.schabi.newpipe.extractor.kiosk.KioskInfo
import org.schabi.newpipe.extractor.localization.ContentCountry
import org.schabi.newpipe.extractor.localization.Localization
import org.schabi.newpipe.extractor.playlist.PlaylistInfo
import org.schabi.newpipe.extractor.search.SearchInfo
import org.schabi.newpipe.extractor.stream.StreamInfo
import org.schabi.newpipe.extractor.stream.AudioStream
import org.schabi.newpipe.extractor.stream.VideoStream
import org.schabi.newpipe.extractor.suggestion.SuggestionExtractor
import java.util.concurrent.ConcurrentHashMap

/**
 * Handles all method channel calls from Flutter for NewPipe Extractor operations.
 * All extraction runs on background threads using Kotlin Coroutines.
 */
class NewPipeMethodHandler : MethodChannel.MethodCallHandler {

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val mainHandler = Handler(Looper.getMainLooper())
    private val gson: Gson = GsonBuilder()
        .serializeNulls()
        .create()
    private val streamInfoCache = ConcurrentHashMap<String, CachedStreamInfo>()
    private val streamInfoCacheTtlMs = 5 * 60 * 1000L

    companion object {
        private var isInitialized = false

        fun initialize() {
            if (!isInitialized) {
                NewPipe.init(FluxTubeDownloader.getInstance())
                isInitialized = true
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        initialize()

        when (call.method) {
            "isAvailable" -> result.success(true)
            "getStreamInfo" -> handleGetStreamInfo(call, result)
            "getStreamInfoFast" -> handleGetStreamInfoFast(call, result)
            "getTrending" -> handleGetTrending(call, result)
            "search" -> handleSearch(call, result)
            "getSearchSuggestions" -> handleGetSearchSuggestions(call, result)
            "getChannel" -> handleGetChannel(call, result)
            "getChannelTab" -> handleGetChannelTab(call, result)
            "getComments" -> handleGetComments(call, result)
            "getMoreComments" -> handleGetMoreComments(call, result)
            "getCommentReplies" -> handleGetCommentReplies(call, result)
            "getPlaylist" -> handleGetPlaylist(call, result)
            "getRelatedStreams" -> handleGetRelatedStreams(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Get video stream info (video details, streams, etc.)
     */
    private fun handleGetStreamInfo(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }

        scope.launch {
            try {
                val streamInfo = getCachedOrExtractStreamInfo(videoId)

                // Get the best quality thumbnail
                val bestThumbnail = streamInfo.thumbnails.maxByOrNull { it.width * it.height }?.url
                    ?: streamInfo.thumbnails.lastOrNull()?.url

                val response = mapOf(
                    "id" to streamInfo.id,
                    "title" to streamInfo.name,
                    "description" to streamInfo.description?.content,
                    "uploaderName" to streamInfo.uploaderName,
                    "uploaderUrl" to streamInfo.uploaderUrl,
                    "uploaderAvatarUrl" to streamInfo.uploaderAvatars.firstOrNull()?.url,
                    "uploaderVerified" to streamInfo.isUploaderVerified,
                    "uploaderSubscriberCount" to streamInfo.uploaderSubscriberCount,
                    "thumbnailUrl" to bestThumbnail,
                    "duration" to streamInfo.duration,
                    "viewCount" to streamInfo.viewCount,
                    "likeCount" to streamInfo.likeCount,
                    "dislikeCount" to streamInfo.dislikeCount,
                    "uploadDate" to streamInfo.uploadDate?.offsetDateTime()?.toString(),
                    "textualUploadDate" to streamInfo.textualUploadDate,
                    "category" to streamInfo.category,
                    "tags" to streamInfo.tags?.toList(),
                    "isLive" to (streamInfo.streamType.name == "LIVE_STREAM"),
                    "hlsUrl" to streamInfo.hlsUrl,
                    "dashMpdUrl" to streamInfo.dashMpdUrl,
                    "audioStreams" to streamInfo.audioStreams.map { mapAudioStream(it) },
                    "videoStreams" to streamInfo.videoStreams.map { mapVideoStream(it) },
                    "videoOnlyStreams" to streamInfo.videoOnlyStreams.map { mapVideoStream(it) },
                    "relatedStreams" to streamInfo.relatedItems.take(20).map { mapInfoItem(it) },
                    "subtitles" to streamInfo.subtitles.map { subtitle ->
                        mapOf(
                            "url" to subtitle.content,
                            "mimeType" to subtitle.format?.mimeType,
                            "languageCode" to subtitle.languageTag,
                            "autoGenerated" to subtitle.isAutoGenerated
                        )
                    }
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to extract stream info", null)
            }
        }
    }

    /**
     * Get video stream info fast (essential data only - no related videos)
     * Returns quickly with just the data needed to start playback
     */
    private fun handleGetStreamInfoFast(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }

        scope.launch {
            try {
                val streamInfo = getCachedOrExtractStreamInfo(videoId)

                // Get the best quality thumbnail
                val bestThumbnail = streamInfo.thumbnails.maxByOrNull { it.width * it.height }?.url
                    ?: streamInfo.thumbnails.lastOrNull()?.url

                // Return only essential data for fast playback start
                val response = mapOf(
                    "id" to streamInfo.id,
                    "title" to streamInfo.name,
                    "uploaderName" to streamInfo.uploaderName,
                    "uploaderUrl" to streamInfo.uploaderUrl,
                    "uploaderAvatarUrl" to streamInfo.uploaderAvatars.firstOrNull()?.url,
                    "uploaderVerified" to streamInfo.isUploaderVerified,
                    "uploaderSubscriberCount" to streamInfo.uploaderSubscriberCount,
                    "thumbnailUrl" to bestThumbnail,
                    "duration" to streamInfo.duration,
                    "viewCount" to streamInfo.viewCount,
                    "likeCount" to streamInfo.likeCount,
                    "dislikeCount" to streamInfo.dislikeCount,
                    "uploadDate" to streamInfo.uploadDate?.offsetDateTime()?.toString(),
                    "textualUploadDate" to streamInfo.textualUploadDate,
                    "isLive" to (streamInfo.streamType.name == "LIVE_STREAM"),
                    "hlsUrl" to streamInfo.hlsUrl,
                    "dashMpdUrl" to streamInfo.dashMpdUrl,
                    "audioStreams" to streamInfo.audioStreams.map { mapAudioStream(it) },
                    "videoStreams" to streamInfo.videoStreams.map { mapVideoStream(it) },
                    "videoOnlyStreams" to streamInfo.videoOnlyStreams.map { mapVideoStream(it) },
                    "subtitles" to streamInfo.subtitles.map { subtitle ->
                        mapOf(
                            "url" to subtitle.content,
                            "mimeType" to subtitle.format?.mimeType,
                            "languageCode" to subtitle.languageTag,
                            "autoGenerated" to subtitle.isAutoGenerated
                        )
                    }
                    // Note: Excludes relatedStreams, description, category, tags for faster response
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to extract stream info", null)
            }
        }
    }

    /**
     * Get trending videos for a specific region
     */
    private fun handleGetTrending(call: MethodCall, result: MethodChannel.Result) {
        val region = call.argument<String>("region") ?: "US"

        scope.launch {
            try {
                val service = ServiceList.YouTube
                val kiosk = service.kioskList.defaultKioskExtractor

                // Set content country for region-specific trending
                NewPipe.setupLocalization(
                    Localization.DEFAULT,
                    ContentCountry(region)
                )

                val kioskInfo = KioskInfo.getInfo(service, kiosk.url)

                val videos = kioskInfo.relatedItems.map { mapInfoItem(it) }

                val response = mapOf(
                    "videos" to videos,
                    "nextPage" to kioskInfo.nextPage?.url
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get trending", null)
            }
        }
    }

    /**
     * Search for videos, channels, or playlists
     */
    private fun handleSearch(call: MethodCall, result: MethodChannel.Result) {
        val query = call.argument<String>("query") ?: run {
            result.error("INVALID_ARGUMENT", "Query is required", null)
            return
        }
        val filter = call.argument<String>("filter") ?: "all"
        val nextPageJson = call.argument<String>("nextPage")

        scope.launch {
            try {
                val service = ServiceList.YouTube
                val contentFilters = when (filter) {
                    "videos" -> listOf("videos")
                    "channels" -> listOf("channels")
                    "playlists" -> listOf("playlists")
                    "music_songs" -> listOf("music_songs")
                    else -> emptyList()
                }

                val searchInfo = if (nextPageJson != null) {
                    // Deserialize the full Page object for pagination
                    val page = deserializePage(nextPageJson)
                    SearchInfo.getMoreItems(
                        service,
                        service.searchQHFactory.fromQuery(query, contentFilters, ""),
                        page
                    ).let { moreItems ->
                        // Create a minimal response for pagination
                        mapOf(
                            "items" to moreItems.items.map { mapInfoItem(it) },
                            "nextPage" to serializePage(moreItems.nextPage)
                        )
                    }
                } else {
                    val info = SearchInfo.getInfo(
                        service,
                        service.searchQHFactory.fromQuery(query, contentFilters, "")
                    )
                    mapOf(
                        "items" to info.relatedItems.map { mapInfoItem(it) },
                        "nextPage" to serializePage(info.nextPage),
                        "searchSuggestion" to info.searchSuggestion,
                        "isCorrectedSearch" to info.isCorrectedSearch
                    )
                }

                sendSuccess(result, gson.toJson(searchInfo))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to search", null)
            }
        }
    }

    /**
     * Get search suggestions
     */
    private fun handleGetSearchSuggestions(call: MethodCall, result: MethodChannel.Result) {
        val query = call.argument<String>("query") ?: run {
            result.error("INVALID_ARGUMENT", "Query is required", null)
            return
        }

        scope.launch {
            try {
                val extractor = ServiceList.YouTube.suggestionExtractor
                val suggestions = extractor.suggestionList(query)
                sendSuccess(result, gson.toJson(suggestions))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get suggestions", null)
            }
        }
    }

    /**
     * Get channel info
     */
    private fun handleGetChannel(call: MethodCall, result: MethodChannel.Result) {
        val channelId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Channel ID is required", null)
            return
        }

        scope.launch {
            try {
                val url = if (channelId.startsWith("http")) {
                    channelId
                } else {
                    "https://www.youtube.com/channel/$channelId"
                }

                val channelInfo = ChannelInfo.getInfo(ServiceList.YouTube, url)

                // Get initial videos from the first tab (usually "Videos")
                var initialVideos: List<Map<String, Any?>> = emptyList()
                var videosNextPage: String? = null

                if (channelInfo.tabs.isNotEmpty()) {
                    try {
                        // Find the videos tab or use the first tab
                        val videosTab = channelInfo.tabs.find { tab ->
                            tab.contentFilters.any { it.contains("videos", ignoreCase = true) }
                        } ?: channelInfo.tabs.firstOrNull()

                        if (videosTab != null) {
                            val tabExtractor = ServiceList.YouTube.getChannelTabExtractor(videosTab)
                            tabExtractor.fetchPage()
                            val initialPage = tabExtractor.initialPage
                            initialVideos = initialPage.items.map { mapInfoItem(it) }
                            videosNextPage = serializePage(initialPage.nextPage)
                        }
                    } catch (tabError: Exception) {
                        // If tab extraction fails, continue without videos
                        android.util.Log.w("NewPipeHandler", "Failed to get videos tab: ${tabError.message}")
                    }
                }

                // Get best quality avatar and banner using ResolutionLevel
                val bestAvatar = channelInfo.avatars
                    .maxWithOrNull(compareBy<org.schabi.newpipe.extractor.Image> {
                        when (it.estimatedResolutionLevel) {
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.HIGH -> 3
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.MEDIUM -> 2
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.LOW -> 1
                            else -> 0
                        }
                    }.thenByDescending { it.width * it.height })?.url

                val bestBanner = channelInfo.banners
                    .maxWithOrNull(compareBy<org.schabi.newpipe.extractor.Image> {
                        when (it.estimatedResolutionLevel) {
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.HIGH -> 3
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.MEDIUM -> 2
                            org.schabi.newpipe.extractor.Image.ResolutionLevel.LOW -> 1
                            else -> 0
                        }
                    }.thenByDescending { it.width * it.height })?.url

                android.util.Log.d("NewPipeHandler", "Selected avatar: ${bestAvatar}")
                android.util.Log.d("NewPipeHandler", "Selected banner: ${bestBanner}")

                val response = mapOf(
                    "id" to channelInfo.id,
                    "name" to channelInfo.name,
                    "description" to channelInfo.description,
                    "avatarUrl" to bestAvatar,
                    "bannerUrl" to bestBanner,
                    "subscriberCount" to channelInfo.subscriberCount,
                    "isVerified" to channelInfo.isVerified,
                    "videos" to initialVideos,
                    "nextPage" to videosNextPage,
                    "tabs" to channelInfo.tabs.map { tab ->
                        // Store tab data in a format we can use to recreate the extractor
                        mapOf(
                            "name" to tab.contentFilters.firstOrNull()?.lowercase(),
                            "url" to tab.url,
                            "id" to tab.id,
                            "contentFilters" to tab.contentFilters
                        )
                    }
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get channel", null)
            }
        }
    }

    /**
     * Get channel tab content (shorts, playlists, etc.) by tab URL
     */
    private fun handleGetChannelTab(call: MethodCall, result: MethodChannel.Result) {
        val tabUrl = call.argument<String>("url") ?: run {
            result.error("INVALID_ARGUMENT", "Tab URL is required", null)
            return
        }
        val tabId = call.argument<String>("id")
        @Suppress("UNCHECKED_CAST")
        val contentFilters = call.argument<List<String>>("contentFilters") ?: emptyList()
        val nextPageJson = call.argument<String>("nextPage")

        scope.launch {
            try {
                // Create the link handler from the tab data
                val linkHandler = ServiceList.YouTube.channelTabLHFactory.fromQuery(
                    tabId ?: tabUrl,
                    contentFilters,
                    ""
                )
                val tabExtractor = ServiceList.YouTube.getChannelTabExtractor(linkHandler)

                val response = if (nextPageJson != null) {
                    // Handle pagination
                    val page = deserializePage(nextPageJson)
                    val moreItems = tabExtractor.getPage(page)
                    mapOf(
                        "videos" to moreItems.items.map { mapInfoItem(it) },
                        "nextPage" to serializePage(moreItems.nextPage)
                    )
                } else {
                    // Initial load
                    tabExtractor.fetchPage()
                    val initialPage = tabExtractor.initialPage
                    mapOf(
                        "videos" to initialPage.items.map { mapInfoItem(it) },
                        "nextPage" to serializePage(initialPage.nextPage)
                    )
                }

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                android.util.Log.e("NewPipeHandler", "Failed to get channel tab: ${e.message}", e)
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get channel tab", null)
            }
        }
    }

    /**
     * Get comments for a video
     */
    private fun handleGetComments(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }

        scope.launch {
            try {
                val url = "https://www.youtube.com/watch?v=$videoId"
                val commentsInfo = CommentsInfo.getInfo(ServiceList.YouTube, url)

                val response = mapOf(
                    "comments" to commentsInfo.relatedItems.map { comment ->
                        mapOf(
                            "id" to comment.commentId,
                            "text" to comment.commentText?.content,
                            "authorName" to comment.uploaderName,
                            "authorUrl" to comment.uploaderUrl,
                            "authorAvatarUrl" to comment.uploaderAvatars.firstOrNull()?.url,
                            "authorVerified" to comment.isUploaderVerified,
                            "likeCount" to comment.likeCount,
                            "replyCount" to comment.replyCount,
                            "isPinned" to comment.isPinned,
                            "isHearted" to comment.isHeartedByUploader,
                            "uploadDate" to comment.textualUploadDate,
                            "repliesPage" to serializePage(comment.replies)
                        )
                    },
                    "nextPage" to serializePage(commentsInfo.nextPage),
                    "commentCount" to commentsInfo.commentsCount,
                    "isDisabled" to commentsInfo.isCommentsDisabled
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get comments", null)
            }
        }
    }

    /**
     * Get more comments (pagination)
     */
    private fun handleGetMoreComments(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }
        val nextPageJson = call.argument<String>("nextPage") ?: run {
            result.error("INVALID_ARGUMENT", "Next page is required", null)
            return
        }

        scope.launch {
            try {
                val url = "https://www.youtube.com/watch?v=$videoId"
                val page = deserializePage(nextPageJson)
                val moreComments = CommentsInfo.getMoreItems(
                    ServiceList.YouTube,
                    url,
                    page
                )

                val response = mapOf(
                    "comments" to moreComments.items.map { comment ->
                        mapOf(
                            "id" to comment.commentId,
                            "text" to comment.commentText?.content,
                            "authorName" to comment.uploaderName,
                            "authorUrl" to comment.uploaderUrl,
                            "authorAvatarUrl" to comment.uploaderAvatars.firstOrNull()?.url,
                            "authorVerified" to comment.isUploaderVerified,
                            "likeCount" to comment.likeCount,
                            "replyCount" to comment.replyCount,
                            "isPinned" to comment.isPinned,
                            "isHearted" to comment.isHeartedByUploader,
                            "uploadDate" to comment.textualUploadDate,
                            "repliesPage" to serializePage(comment.replies)
                        )
                    },
                    "nextPage" to serializePage(moreComments.nextPage)
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get more comments", null)
            }
        }
    }

    /**
     * Get comment replies
     */
    private fun handleGetCommentReplies(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }
        val repliesPageJson = call.argument<String>("repliesPage") ?: run {
            result.error("INVALID_ARGUMENT", "Replies page is required", null)
            return
        }

        scope.launch {
            try {
                val url = "https://www.youtube.com/watch?v=$videoId"
                val page = deserializePage(repliesPageJson)
                val replies = CommentsInfo.getMoreItems(
                    ServiceList.YouTube,
                    url,
                    page
                )

                val response = mapOf(
                    "comments" to replies.items.map { comment ->
                        mapOf(
                            "id" to comment.commentId,
                            "text" to comment.commentText?.content,
                            "authorName" to comment.uploaderName,
                            "authorUrl" to comment.uploaderUrl,
                            "authorAvatarUrl" to comment.uploaderAvatars.firstOrNull()?.url,
                            "authorVerified" to comment.isUploaderVerified,
                            "likeCount" to comment.likeCount,
                            "replyCount" to comment.replyCount,
                            "isPinned" to comment.isPinned,
                            "isHearted" to comment.isHeartedByUploader,
                            "uploadDate" to comment.textualUploadDate,
                            "repliesPage" to serializePage(comment.replies)
                        )
                    },
                    "nextPage" to serializePage(replies.nextPage)
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get comment replies", null)
            }
        }
    }

    /**
     * Get playlist info
     */
    private fun handleGetPlaylist(call: MethodCall, result: MethodChannel.Result) {
        val playlistId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Playlist ID is required", null)
            return
        }

        scope.launch {
            try {
                val url = if (playlistId.startsWith("http")) {
                    playlistId
                } else {
                    "https://www.youtube.com/playlist?list=$playlistId"
                }

                val playlistInfo = PlaylistInfo.getInfo(ServiceList.YouTube, url)

                // Get best quality thumbnails
                val bestPlaylistThumbnail = playlistInfo.thumbnails.maxByOrNull { it.width * it.height }?.url
                    ?: playlistInfo.thumbnails.lastOrNull()?.url
                val bestUploaderAvatar = playlistInfo.uploaderAvatars.maxByOrNull { it.width * it.height }?.url
                    ?: playlistInfo.uploaderAvatars.lastOrNull()?.url

                val response = mapOf(
                    "id" to playlistInfo.id,
                    "name" to playlistInfo.name,
                    "thumbnailUrl" to bestPlaylistThumbnail,
                    "uploaderName" to playlistInfo.uploaderName,
                    "uploaderUrl" to playlistInfo.uploaderUrl,
                    "uploaderAvatarUrl" to bestUploaderAvatar,
                    "streamCount" to playlistInfo.streamCount,
                    "videos" to playlistInfo.relatedItems.map { mapInfoItem(it) },
                    "nextPage" to playlistInfo.nextPage?.url
                )

                sendSuccess(result, gson.toJson(response))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get playlist", null)
            }
        }
    }

    /**
     * Get related streams for a video
     */
    private fun handleGetRelatedStreams(call: MethodCall, result: MethodChannel.Result) {
        val videoId = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENT", "Video ID is required", null)
            return
        }

        scope.launch {
            try {
                val streamInfo = getCachedOrExtractStreamInfo(videoId)

                val relatedVideos = streamInfo.relatedItems.map { mapInfoItem(it) }
                sendSuccess(result, gson.toJson(relatedVideos))
            } catch (e: Exception) {
                sendError(result, "EXTRACTION_ERROR", e.message ?: "Failed to get related streams", null)
            }
        }
    }

    // Helper methods

    private fun getCachedOrExtractStreamInfo(videoId: String): StreamInfo {
        val now = System.currentTimeMillis()
        val cached = streamInfoCache[videoId]
        if (cached != null && now - cached.timestampMs <= streamInfoCacheTtlMs) {
            return cached.streamInfo
        }

        val url = "https://www.youtube.com/watch?v=$videoId"
        val streamInfo = StreamInfo.getInfo(ServiceList.YouTube, url)
        streamInfoCache[videoId] = CachedStreamInfo(streamInfo, now)
        return streamInfo
    }

    private fun mapAudioStream(stream: AudioStream): Map<String, Any?> {
        val itagItem = stream.itagItem
        return mapOf(
            "url" to stream.content,
            "averageBitrate" to stream.averageBitrate,
            "format" to stream.format?.name,
            "mimeType" to stream.format?.mimeType,
            "codec" to stream.codec,
            "quality" to stream.quality,
            "id" to stream.id,
            "itag" to stream.itag,
            // DASH manifest fields from ItagItem
            "initStart" to itagItem?.initStart,
            "initEnd" to itagItem?.initEnd,
            "indexStart" to itagItem?.indexStart,
            "indexEnd" to itagItem?.indexEnd,
            "contentLength" to itagItem?.contentLength,
            "bitrate" to itagItem?.bitrate,
            "approxDurationMs" to itagItem?.approxDurationMs,
            "audioChannels" to itagItem?.audioChannels,
            "sampleRate" to itagItem?.sampleRate
        )
    }

    private fun mapVideoStream(stream: VideoStream): Map<String, Any?> {
        val itagItem = stream.itagItem
        return mapOf(
            "url" to stream.content,
            "resolution" to stream.resolution,
            "format" to stream.format?.name,
            "mimeType" to stream.format?.mimeType,
            "codec" to stream.codec,
            "quality" to stream.quality,
            "width" to stream.width,
            "height" to stream.height,
            "fps" to stream.fps,
            "isVideoOnly" to stream.isVideoOnly,
            "id" to stream.id,
            "itag" to stream.itag,
            // DASH manifest fields from ItagItem
            "initStart" to itagItem?.initStart,
            "initEnd" to itagItem?.initEnd,
            "indexStart" to itagItem?.indexStart,
            "indexEnd" to itagItem?.indexEnd,
            "contentLength" to itagItem?.contentLength,
            "bitrate" to itagItem?.bitrate,
            "approxDurationMs" to itagItem?.approxDurationMs
        )
    }

    private fun mapInfoItem(item: InfoItem): Map<String, Any?> {
        // Smart thumbnail selection with different logic for channels vs videos
        val bestThumbnail = run {
            // For channels, use their avatars/thumbnails directly without trying to construct URLs
            if (item is org.schabi.newpipe.extractor.channel.ChannelInfoItem) {
                if (item.thumbnails.isNotEmpty()) {
                    android.util.Log.d("NewPipeHandler", "Channel thumbnails available: ${item.thumbnails.size}")

                    // Select best quality channel avatar using ResolutionLevel
                    val best = item.thumbnails.maxWithOrNull(
                        compareBy<org.schabi.newpipe.extractor.Image> {
                            when (it.estimatedResolutionLevel) {
                                org.schabi.newpipe.extractor.Image.ResolutionLevel.HIGH -> 3
                                org.schabi.newpipe.extractor.Image.ResolutionLevel.MEDIUM -> 2
                                org.schabi.newpipe.extractor.Image.ResolutionLevel.LOW -> 1
                                else -> 0
                            }
                        }.thenByDescending { it.width * it.height }
                    )

                    if (best != null) {
                        android.util.Log.d("NewPipeHandler", "Selected channel avatar: ${best.estimatedResolutionLevel} (${best.width}x${best.height})")
                        return@run best.url
                    }
                }
                android.util.Log.w("NewPipeHandler", "No channel avatar available")
                return@run null
            }

            // For videos/streams/playlists, use smart thumbnail selection with fallback
            if (item.thumbnails.isNotEmpty()) {
                android.util.Log.d("NewPipeHandler", "Thumbnails available: ${item.thumbnails.size}")

                // Check if we have any HIGH quality images (720p+)
                val highQuality = item.thumbnails.filter {
                    it.estimatedResolutionLevel == org.schabi.newpipe.extractor.Image.ResolutionLevel.HIGH
                }

                val best = when {
                    // If we have HIGH quality, use it
                    highQuality.isNotEmpty() -> {
                        highQuality.maxByOrNull { it.width * it.height }
                    }
                    // If all images are low-res (< 480px), skip to URL construction
                    item.thumbnails.all { it.width < 480 } -> {
                        android.util.Log.d("NewPipeHandler", "All thumbnails are low-res, will construct HQ URL")
                        null
                    }
                    // Otherwise use largest available
                    else -> {
                        item.thumbnails.maxByOrNull { it.width * it.height }
                    }
                }

                item.thumbnails.forEach {
                    android.util.Log.d("NewPipeHandler", "  - ${it.estimatedResolutionLevel} (${it.width}x${it.height}): ${it.url}")
                }

                if (best != null) {
                    android.util.Log.d("NewPipeHandler", "Selected: ${best.estimatedResolutionLevel} (${best.width}x${best.height})")
                    return@run best.url  // Return early with good thumbnail
                }
            }

            // If we reach here, either no thumbnails or all were low-res
            // Try constructing high-quality URL from video ID
            if (item.url != null) {
                android.util.Log.d("NewPipeHandler", "Falling back to URL construction")
                // Extract video ID from various URL formats:
                // /watch?v=VIDEO_ID
                // /shorts/VIDEO_ID
                // /VIDEO_ID
                val videoId = when {
                    item.url!!.contains("/watch?v=") -> {
                        item.url!!.substringAfter("v=").substringBefore("&").substringBefore("?")
                    }
                    item.url!!.contains("/shorts/") -> {
                        item.url!!.substringAfter("/shorts/").substringBefore("?").substringBefore("&")
                    }
                    item.url!!.startsWith("/") && item.url!!.length == 12 -> {
                        // Likely just /VIDEO_ID (11 chars + leading slash)
                        item.url!!.substring(1)
                    }
                    else -> {
                        // Try last segment after /
                        item.url!!.substringAfterLast("/").substringBefore("?").substringBefore("&")
                    }
                }

                if (videoId.isNotEmpty() && videoId.length == 11) {  // YouTube video IDs are 11 chars
                    android.util.Log.d("NewPipeHandler", "Constructing max quality thumbnail for video ID: $videoId")
                    // Use maxresdefault for best quality (1280x720+)
                    return@run "https://i.ytimg.com/vi/$videoId/maxresdefault.jpg"
                } else {
                    android.util.Log.w("NewPipeHandler", "Can't extract video ID from: ${item.url}, extracted: $videoId")
                }
            }

            // Final fallback - no thumbnail available
            android.util.Log.w("NewPipeHandler", "No thumbnail URL could be determined")
            null
        }

        return mapOf(
            "url" to item.url,
            "name" to item.name,
            "thumbnailUrl" to bestThumbnail,
            "type" to item.infoType.name,
            // Stream-specific fields
            "uploaderName" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.uploaderName,
            "uploaderUrl" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.uploaderUrl,
            "uploaderAvatarUrl" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.uploaderAvatars?.maxWithOrNull(
                compareBy<org.schabi.newpipe.extractor.Image> {
                    when (it.estimatedResolutionLevel) {
                        org.schabi.newpipe.extractor.Image.ResolutionLevel.HIGH -> 3
                        org.schabi.newpipe.extractor.Image.ResolutionLevel.MEDIUM -> 2
                        org.schabi.newpipe.extractor.Image.ResolutionLevel.LOW -> 1
                        else -> 0
                    }
                }.thenByDescending { it.width * it.height }
            )?.url,
            "uploaderVerified" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.isUploaderVerified,
            "duration" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.duration,
            "viewCount" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.viewCount,
            "uploadDate" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.textualUploadDate,
            "isLive" to ((item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.streamType?.name == "LIVE_STREAM"),
            "isShort" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.isShortFormContent,
            // Content availability (v0.25.0+): UNKNOWN, AVAILABLE, MEMBERSHIP, PAID, UPCOMING
            "contentAvailability" to (item as? org.schabi.newpipe.extractor.stream.StreamInfoItem)?.contentAvailability?.name,
            // Channel-specific fields
            "subscriberCount" to (item as? org.schabi.newpipe.extractor.channel.ChannelInfoItem)?.subscriberCount,
            "isVerified" to (item as? org.schabi.newpipe.extractor.channel.ChannelInfoItem)?.isVerified,
            "description" to (item as? org.schabi.newpipe.extractor.channel.ChannelInfoItem)?.description,
            // Playlist-specific fields
            "streamCount" to (item as? org.schabi.newpipe.extractor.playlist.PlaylistInfoItem)?.streamCount,
            // Add uploader info for playlists (they have uploaderName unlike StreamInfoItem)
            "playlistUploaderName" to (item as? org.schabi.newpipe.extractor.playlist.PlaylistInfoItem)?.uploaderName,
            "playlistUploaderUrl" to (item as? org.schabi.newpipe.extractor.playlist.PlaylistInfoItem)?.uploaderUrl
        )
    }

    /**
     * Serialize a Page object to JSON string for passing through MethodChannel
     */
    private fun serializePage(page: org.schabi.newpipe.extractor.Page?): String? {
        if (page == null) return null

        val pageMap = mapOf(
            "url" to page.url,
            "id" to page.id,
            "ids" to page.ids,
            "body" to page.body?.let { android.util.Base64.encodeToString(it, android.util.Base64.NO_WRAP) }
        )
        return gson.toJson(pageMap)
    }

    /**
     * Deserialize a JSON string back to a Page object
     */
    private fun deserializePage(json: String): org.schabi.newpipe.extractor.Page {
        val pageMap = gson.fromJson(json, Map::class.java)
        val url = pageMap["url"] as? String
        val id = pageMap["id"] as? String
        @Suppress("UNCHECKED_CAST")
        val ids = (pageMap["ids"] as? List<*>)?.filterIsInstance<String>()
        val bodyBase64 = pageMap["body"] as? String
        val body = bodyBase64?.let { android.util.Base64.decode(it, android.util.Base64.NO_WRAP) }

        return when {
            ids != null && body != null -> org.schabi.newpipe.extractor.Page(url, id, ids, null, body)
            ids != null -> org.schabi.newpipe.extractor.Page(ids)
            body != null -> org.schabi.newpipe.extractor.Page(url, id, body)
            id != null -> org.schabi.newpipe.extractor.Page(url, id)
            url != null -> org.schabi.newpipe.extractor.Page(url)
            else -> throw IllegalArgumentException("Invalid Page data: no url or ids provided")
        }
    }

    private fun sendSuccess(result: MethodChannel.Result, data: String) {
        mainHandler.post {
            result.success(data)
        }
    }

    private fun sendError(result: MethodChannel.Result, code: String, message: String, details: Any?) {
        mainHandler.post {
            result.error(code, message, details)
        }
    }

    private data class CachedStreamInfo(
        val streamInfo: StreamInfo,
        val timestampMs: Long
    )

    /**
     * Clean up resources when no longer needed
     */
    fun dispose() {
        scope.cancel()
    }
}
