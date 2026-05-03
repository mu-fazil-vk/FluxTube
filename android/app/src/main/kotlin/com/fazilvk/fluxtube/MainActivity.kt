package com.fazilvk.fluxtube

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.graphics.Rect
import android.os.Build
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.fazilvk.fluxtube.newpipe.NewPipeMethodHandler
import com.fazilvk.fluxtube.player.NewPipeExoPlayerViewFactory

class MainActivity: AudioServiceFragmentActivity() {
    companion object {
        private const val NEWPIPE_CHANNEL = "com.fazilvk.fluxtube/newpipe"
        private const val PIP_CHANNEL = "com.fazilvk.fluxtube/pip"
        private const val MUXER_CHANNEL = "com.fazilvk.fluxtube/muxer"
    }

    private var newPipeHandler: NewPipeMethodHandler? = null
    private var pipChannel: MethodChannel? = null
    private var muxerHandler: MediaMuxerHandler? = null

    // PiP state
    private var isPipModeEnabled = false
    private var isVideoPlaying = false
    private var videoAspectRatio: Rational = Rational(16, 9)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize NewPipe method handler
        newPipeHandler = NewPipeMethodHandler()

        // Register NewPipe method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NEWPIPE_CHANNEL)
            .setMethodCallHandler(newPipeHandler)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "fluxtube/newpipe_exoplayer",
                NewPipeExoPlayerViewFactory(flutterEngine.dartExecutor.binaryMessenger)
            )

        // Initialize and register MediaMuxer handler
        muxerHandler = MediaMuxerHandler()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MUXER_CHANNEL)
            .setMethodCallHandler(muxerHandler)

        // Register PiP method channel
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL)
        pipChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPip" -> {
                    val aspectRatioWidth = call.argument<Int>("aspectRatioWidth") ?: 16
                    val aspectRatioHeight = call.argument<Int>("aspectRatioHeight") ?: 9
                    videoAspectRatio = Rational(aspectRatioWidth, aspectRatioHeight)
                    isVideoPlaying = true

                    val success = enterPipMode()
                    result.success(success)
                }
                "exitPip" -> {
                    // PiP exit is handled by the system, but we can update our state
                    isVideoPlaying = false
                    result.success(true)
                }
                "setVideoPlaying" -> {
                    isVideoPlaying = call.argument<Boolean>("isPlaying") ?: false
                    result.success(true)
                }
                "isPipSupported" -> {
                    result.success(isPipSupported())
                }
                "isInPipMode" -> {
                    result.success(isInPictureInPictureMode)
                }
                "setAspectRatio" -> {
                    val width = call.argument<Int>("width") ?: 16
                    val height = call.argument<Int>("height") ?: 9
                    videoAspectRatio = Rational(width, height)
                    updatePipParams()
                    result.success(true)
                }
                "enableAutoPip" -> {
                    isPipModeEnabled = call.argument<Boolean>("enabled") ?: false
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isPipSupported(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
    }

    private fun enterPipMode(): Boolean {
        if (!isPipSupported()) return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(videoAspectRatio)
                    .build()

                enterPictureInPictureMode(params)
                return true
            } catch (e: Exception) {
                e.printStackTrace()
                return false
            }
        }
        return false
    }

    private fun updatePipParams() {
        if (!isPipSupported() || !isInPictureInPictureMode) return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(videoAspectRatio)
                    .build()

                setPictureInPictureParams(params)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()

        // Auto-enter PiP when user leaves the app (presses home button)
        // Only if video is playing and auto-PiP is enabled
        if (isPipModeEnabled && isVideoPlaying && isPipSupported()) {
            enterPipMode()
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)

        // Notify Flutter about PiP mode change
        // Only invoke if the engine is still attached (activity not destroyed)
        try {
            if (!isDestroyed && !isFinishing) {
                pipChannel?.invokeMethod("onPipModeChanged", mapOf(
                    "isInPipMode" to isInPictureInPictureMode
                ))
            }
        } catch (e: Exception) {
            // Ignore - Flutter engine may have been detached
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        // Clear PiP channel to prevent callbacks after destruction
        pipChannel?.setMethodCallHandler(null)
        pipChannel = null
        newPipeHandler?.dispose()
        super.onDestroy()
    }
}
