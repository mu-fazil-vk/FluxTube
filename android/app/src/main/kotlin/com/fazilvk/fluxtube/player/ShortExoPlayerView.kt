package com.fazilvk.fluxtube.player

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.TextureView
import android.view.View
import android.widget.FrameLayout
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.dash.DashMediaSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.source.MergingMediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.ui.AspectRatioFrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * A looping, self-contained player for the Shorts feed. Unlike
 * [NewPipeExoPlayerView] it owns its ExoPlayer, so the current and the
 * preloaded short can coexist; the player is released with the view.
 */
@UnstableApi
class ShortExoPlayerView(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    params: Map<*, *>
) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "com.fazilvk.fluxtube/short_exoplayer_$viewId")
    private val mainHandler = Handler(Looper.getMainLooper())

    private val dataSourceFactory: DataSource.Factory = CacheDataSource.Factory()
        .setCache(NewPipeSharedExoPlayer.cache(context))
        .setUpstreamDataSourceFactory(
            DefaultHttpDataSource.Factory()
                .setUserAgent(USER_AGENT)
                .setAllowCrossProtocolRedirects(true)
                .setConnectTimeoutMs(15_000)
                .setReadTimeoutMs(15_000)
        )
        .setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR)

    private val player: ExoPlayer = ExoPlayer.Builder(context.applicationContext)
        .setLoadControl(
            DefaultLoadControl.Builder()
                // Shorts are short; a small buffer keeps two players cheap.
                .setBufferDurationsMs(5_000, 15_000, 400, 1_000)
                .build()
        )
        .build()
        .apply { repeatMode = Player.REPEAT_MODE_ONE }

    private val textureView = TextureView(context)
    private val aspectLayout = AspectRatioFrameLayout(context).apply {
        resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
        addView(textureView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
    }
    private val root = FrameLayout(context).apply {
        setBackgroundColor(android.graphics.Color.BLACK)
        addView(aspectLayout, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
            Gravity.CENTER
        ))
    }

    private val ticker = object : Runnable {
        override fun run() {
            sendState()
            if (player.isPlaying) mainHandler.postDelayed(this, TICK_MS)
        }
    }

    private val listener = object : Player.Listener {
        override fun onVideoSizeChanged(videoSize: VideoSize) {
            if (videoSize.width > 0 && videoSize.height > 0) {
                aspectLayout.setAspectRatio(
                    videoSize.width * videoSize.pixelWidthHeightRatio / videoSize.height
                )
            }
        }

        override fun onPlaybackStateChanged(playbackState: Int) = scheduleTicks()
        override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) = scheduleTicks()
        override fun onIsPlayingChanged(isPlaying: Boolean) {
            root.keepScreenOn = isPlaying
            scheduleTicks()
        }

        override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
            channel.invokeMethod("onError", mapOf("message" to (error.message ?: "Playback failed")))
        }
    }

    init {
        channel.setMethodCallHandler(this)
        player.setVideoTextureView(textureView)
        player.addListener(listener)
        load(params)
    }

    override fun getView(): View = root

    override fun dispose() {
        mainHandler.removeCallbacks(ticker)
        channel.setMethodCallHandler(null)
        player.removeListener(listener)
        player.release()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> player.play()
            "pause" -> player.pause()
            "seekTo" -> player.seekTo(((call.argument<Number>("positionMs") ?: 0).toLong()).coerceAtLeast(0))
            "load" -> load(call.arguments as? Map<*, *> ?: emptyMap<String, Any?>())
            "setSpeed" -> player.setPlaybackSpeed(
                ((call.argument<Number>("speed") ?: 1.0).toFloat()).coerceIn(0.25f, 3.0f)
            )
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    private fun load(params: Map<*, *>) {
        val source = when (params["sourceType"] as? String ?: "progressive") {
            "dash" -> (params["manifestUrl"] as? String)?.takeIf { it.isNotBlank() }?.let {
                DashMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(Uri.parse(it)))
            }
            "hls" -> (params["manifestUrl"] as? String)?.takeIf { it.isNotBlank() }?.let {
                HlsMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(Uri.parse(it)))
            }
            "merging" -> {
                val video = params["videoUrl"] as? String
                val audio = params["audioUrl"] as? String
                if (video.isNullOrBlank() || audio.isNullOrBlank()) null else {
                    val factory = ProgressiveMediaSource.Factory(dataSourceFactory)
                    MergingMediaSource(
                        factory.createMediaSource(MediaItem.fromUri(Uri.parse(video))),
                        factory.createMediaSource(MediaItem.fromUri(Uri.parse(audio)))
                    )
                }
            }
            else -> (params["videoUrl"] as? String)?.takeIf { it.isNotBlank() }?.let {
                ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(Uri.parse(it)))
            }
        } ?: return

        player.setMediaSource(source)
        player.playWhenReady = params["playWhenReady"] as? Boolean ?: false
        player.prepare()
        scheduleTicks()
    }

    private fun scheduleTicks() {
        mainHandler.removeCallbacks(ticker)
        sendState()
        if (player.isPlaying) mainHandler.postDelayed(ticker, TICK_MS)
    }

    private fun sendState() {
        val duration = player.duration
        channel.invokeMethod(
            "onState",
            mapOf(
                "isPlaying" to player.isPlaying,
                "playWhenReady" to (player.playWhenReady && player.playbackState != Player.STATE_IDLE),
                "isBuffering" to (player.playbackState == Player.STATE_BUFFERING),
                "positionMs" to player.currentPosition.coerceAtLeast(0),
                "durationMs" to if (duration == C.TIME_UNSET) 0 else duration.coerceAtLeast(0)
            )
        )
    }

    companion object {
        private const val TICK_MS = 250L
        private const val USER_AGENT =
            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36"
    }
}

@UnstableApi
class ShortExoPlayerViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        ShortExoPlayerView(context, messenger, viewId, args as? Map<*, *> ?: emptyMap<String, Any?>())
}
