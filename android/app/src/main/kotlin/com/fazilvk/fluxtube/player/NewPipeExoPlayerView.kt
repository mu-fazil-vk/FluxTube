package com.fazilvk.fluxtube.player

import android.content.Context
import android.net.Uri
import android.view.View
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.dash.DashMediaSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.source.MergingMediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

@UnstableApi
object NewPipeSharedExoPlayer {
    private var player: ExoPlayer? = null
    var sourceKey: String? = null

    fun get(context: Context): ExoPlayer {
        val existing = player
        if (existing != null) return existing

        val trackSelector = DefaultTrackSelector(context).apply {
            setParameters(
                buildUponParameters()
                    .setTunnelingEnabled(true)
                    .setAllowVideoMixedMimeTypeAdaptiveness(true)
                    .setAllowAudioMixedMimeTypeAdaptiveness(true)
            )
        }

        return ExoPlayer.Builder(context.applicationContext)
            .setTrackSelector(trackSelector)
            .build()
            .also { player = it }
    }

    fun play(): Boolean {
        val existing = player ?: return false
        existing.play()
        return true
    }

    fun pause(): Boolean {
        val existing = player ?: return false
        existing.pause()
        return true
    }

    fun stop(): Boolean {
        val existing = player ?: return false
        existing.stop()
        sourceKey = null
        return true
    }

    fun seekTo(positionMs: Long): Boolean {
        val existing = player ?: return false
        existing.seekTo(positionMs.coerceAtLeast(0))
        return true
    }

    fun seekBy(deltaMs: Long): Long {
        val existing = player ?: return 0L
        val duration = existing.duration
        val upperBound = if (duration == C.TIME_UNSET) Long.MAX_VALUE else duration.coerceAtLeast(0)
        val target = (existing.currentPosition + deltaMs)
            .coerceAtLeast(0)
            .coerceAtMost(upperBound)
        existing.seekTo(target)
        return target
    }
}

@UnstableApi
class NewPipeExoPlayerView(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    creationParams: Map<*, *>
) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(
        messenger,
        "com.fazilvk.fluxtube/newpipe_exoplayer_$viewId"
    )
    private val httpDataSourceFactory = DefaultHttpDataSource.Factory()
        .setUserAgent(USER_AGENT)
        .setAllowCrossProtocolRedirects(true)
    private val mediaSourceFactory = ProgressiveMediaSource.Factory(httpDataSourceFactory)
    private val player = NewPipeSharedExoPlayer.get(context)
    private val playerView = PlayerView(context).apply {
        player = this@NewPipeExoPlayerView.player
        useController = false
        resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
        setShowBuffering(PlayerView.SHOW_BUFFERING_NEVER)
    }

    private var sourceType = ""
    private var isLive = false

    init {
        channel.setMethodCallHandler(this)
        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                sendState()
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                sendState()
            }

            override fun onPlayerError(error: PlaybackException) {
                channel.invokeMethod(
                    "onError",
                    mapOf(
                        "message" to (error.message ?: "Playback error"),
                        "code" to error.errorCodeName
                    )
                )
            }
        })
        load(creationParams)
    }

    override fun getView(): View = playerView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        playerView.player = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                player.play()
                result.success(null)
            }
            "pause" -> {
                player.pause()
                result.success(null)
            }
            "stop" -> {
                player.stop()
                NewPipeSharedExoPlayer.sourceKey = null
                result.success(null)
            }
            "seekTo" -> {
                val positionMs = (call.argument<Number>("positionMs") ?: 0).toLong()
                player.seekTo(positionMs.coerceAtLeast(0))
                result.success(null)
            }
            "load" -> {
                val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
                val keepPosition = args["keepPosition"] as? Boolean ?: false
                val mergedArgs = args.toMutableMap()
                if (keepPosition && !mergedArgs.containsKey("startPositionMs")) {
                    mergedArgs["startPositionMs"] = player.currentPosition.coerceAtLeast(0)
                }
                load(mergedArgs)
                result.success(null)
            }
            "setSpeed" -> {
                val speed = (call.argument<Number>("speed") ?: 1.0).toFloat()
                player.setPlaybackSpeed(speed.coerceIn(0.25f, 2.0f))
                result.success(null)
            }
            "getPosition" -> result.success(player.currentPosition.coerceAtLeast(0))
            "getDuration" -> {
                val duration = player.duration
                result.success(if (duration == C.TIME_UNSET) 0 else duration.coerceAtLeast(0))
            }
            "isPlaying" -> result.success(player.isPlaying)
            "setResizeMode" -> {
                playerView.resizeMode = resizeModeFrom(call.argument<String>("fitMode"))
                result.success(null)
            }
            "reattach" -> {
                playerView.player = null
                playerView.player = player
                playerView.invalidate()
                sendState()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun load(params: Map<*, *>) {
        val attachOnly = params["attachOnly"] as? Boolean ?: false
        if (attachOnly) {
            playerView.resizeMode = resizeModeFrom(params["fitMode"] as? String)
            playerView.player = player
            sendState()
            return
        }

        sourceType = params["sourceType"] as? String ?: "progressive"
        isLive = params["isLive"] as? Boolean ?: false
        val sourceKey = params["sourceKey"] as? String
        val startPositionMs = (params["startPositionMs"] as? Number)?.toLong() ?: 0L
        val playWhenReady = params["playWhenReady"] as? Boolean ?: true
        playerView.resizeMode = resizeModeFrom(params["fitMode"] as? String)

        if (!sourceKey.isNullOrBlank() &&
            NewPipeSharedExoPlayer.sourceKey == sourceKey &&
            player.mediaItemCount > 0
        ) {
            player.playWhenReady = playWhenReady
            sendState()
            return
        }

        val mediaSource = when (sourceType) {
            "dash" -> {
                val manifestUrl = params["manifestUrl"] as? String
                if (manifestUrl.isNullOrBlank()) return
                DashMediaSource.Factory(httpDataSourceFactory)
                    .createMediaSource(mediaItem(manifestUrl, params))
            }
            "hls" -> {
                val manifestUrl = params["manifestUrl"] as? String
                if (manifestUrl.isNullOrBlank()) return
                HlsMediaSource.Factory(httpDataSourceFactory)
                    .createMediaSource(mediaItem(manifestUrl, params))
            }
            "merging" -> {
                val videoUrl = params["videoUrl"] as? String
                val audioUrl = params["audioUrl"] as? String
                if (videoUrl.isNullOrBlank() || audioUrl.isNullOrBlank()) return
                val videoSource = mediaSourceFactory
                    .createMediaSource(mediaItem(videoUrl, params))
                val audioSource = mediaSourceFactory
                    .createMediaSource(MediaItem.fromUri(Uri.parse(audioUrl)))
                MergingMediaSource(videoSource, audioSource)
            }
            else -> {
                val videoUrl = params["videoUrl"] as? String
                if (videoUrl.isNullOrBlank()) return
                mediaSourceFactory.createMediaSource(mediaItem(videoUrl, params))
            }
        }

        player.setMediaSource(mediaSource, startPositionMs.coerceAtLeast(0))
        NewPipeSharedExoPlayer.sourceKey = sourceKey
        player.playWhenReady = playWhenReady
        player.prepare()
        sendState()
    }

    private fun mediaItem(url: String, params: Map<*, *>): MediaItem {
        val selectedSubtitleUrl = params["selectedSubtitleUrl"] as? String
        val selectedSubtitleLanguage = params["selectedSubtitleLanguage"] as? String
        val builder = MediaItem.Builder().setUri(Uri.parse(url))
        if (!selectedSubtitleUrl.isNullOrBlank()) {
            builder.setSubtitleConfigurations(
                listOf(
                    MediaItem.SubtitleConfiguration.Builder(Uri.parse(selectedSubtitleUrl))
                        .setMimeType(mimeTypeForSubtitle(selectedSubtitleUrl))
                        .setLanguage(selectedSubtitleLanguage)
                        .setSelectionFlags(C.SELECTION_FLAG_DEFAULT)
                        .build()
                )
            )
        }
        return builder.build()
    }

    private fun mimeTypeForSubtitle(url: String): String {
        val lower = url.lowercase()
        return when {
            lower.contains("ttml") || lower.endsWith(".ttml") || lower.endsWith(".xml") ->
                MimeTypes.APPLICATION_TTML
            lower.endsWith(".srt") -> MimeTypes.APPLICATION_SUBRIP
            else -> MimeTypes.TEXT_VTT
        }
    }

    private fun sendState() {
        val duration = player.duration
        channel.invokeMethod(
            "onState",
            mapOf(
                "isPlaying" to player.isPlaying,
                "isBuffering" to (player.playbackState == Player.STATE_BUFFERING),
                "positionMs" to player.currentPosition.coerceAtLeast(0),
                "durationMs" to if (duration == C.TIME_UNSET) 0 else duration.coerceAtLeast(0),
                "sourceType" to sourceType,
                "isLive" to isLive
            )
        )
    }

    private fun resizeModeFrom(fitMode: String?): Int {
        return when (fitMode) {
            "cover" -> AspectRatioFrameLayout.RESIZE_MODE_ZOOM
            "fill" -> AspectRatioFrameLayout.RESIZE_MODE_FILL
            else -> AspectRatioFrameLayout.RESIZE_MODE_FIT
        }
    }

    companion object {
        private const val USER_AGENT =
            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36"
    }
}
