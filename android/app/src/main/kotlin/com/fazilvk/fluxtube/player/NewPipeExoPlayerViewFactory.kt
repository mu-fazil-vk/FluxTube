package com.fazilvk.fluxtube.player

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NewPipeExoPlayerViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private val controlChannel = MethodChannel(
        messenger,
        "com.fazilvk.fluxtube/newpipe_exoplayer_control"
    )

    init {
        controlChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> result.success(NewPipeSharedExoPlayer.play())
                "pause" -> result.success(NewPipeSharedExoPlayer.pause())
                "stop" -> result.success(NewPipeSharedExoPlayer.stop())
                "seekTo" -> {
                    val positionMs = (call.argument<Number>("positionMs") ?: 0).toLong()
                    result.success(NewPipeSharedExoPlayer.seekTo(positionMs))
                }
                "seekBy" -> {
                    val deltaMs = (call.argument<Number>("deltaMs") ?: 0).toLong()
                    result.success(NewPipeSharedExoPlayer.seekBy(deltaMs))
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *> ?: emptyMap<String, Any?>()
        return NewPipeExoPlayerView(context, messenger, viewId, creationParams)
    }
}
