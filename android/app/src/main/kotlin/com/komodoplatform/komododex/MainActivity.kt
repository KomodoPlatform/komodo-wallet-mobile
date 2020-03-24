package com.komodoplatform.atomicdex

import android.os.Build
import android.os.Bundle
import io.flutter.app.FlutterFragmentActivity
import io.flutter.plugin.common.EventChannel 
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.ViewTreeObserver
import android.view.WindowManager
import androidx.annotation.RequiresApi

class MainActivity: FlutterFragmentActivity() {
  private var logC: EventChannel? = null
  private var logSink: EventChannel.EventSink? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    //make transparent status bar
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP)
      changeStatuBar()
    GeneratedPluginRegistrant.registerWith(this)
    //Remove full screen flag after load
    val vto = flutterView.viewTreeObserver

    vto.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener{
      override fun onGlobalLayout() {
        flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
      }
    })
    nativeC();
    logC();
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun changeStatuBar() {
    window.statusBarColor = 0x00000000
  }

  private fun nativeC() {
    // https://flutter.dev/docs/development/platform-integration/platform-channels?tab=android-channel-kotlin-tab#step-3-add-an-android-platform-specific-implementation
    MethodChannel (getFlutterView(), "com.komodoplatform.atomicdex/nativeC") .setMethodCallHandler {
      call, result ->  // NB: invoked on the main thread.
      if (call.method == "ping") {  // Allows us to test the channel.
        // Example using the `logSink`:
        // 
        //     logSink?.success ("ping] Logging from MainActivity.kt; BUILD_TIME: " + BuildConfig.BUILD_TIME)

        result.success ("pong")
      } else if (call.method == "BUILD_TIME") {
        result.success (BuildConfig.BUILD_TIME)
      } else {
        result.notImplemented()}}}

  private fun logC() {
    // https://blog.testfairy.com/listeners-with-eventchannel-in-flutter/
    // https://api.flutter.dev/javadoc/index.html?io/flutter/plugin/common/EventChannel.html
    val chan = EventChannel (getFlutterView(), "AtomicDEX/logC")
    chan.setStreamHandler (object: EventChannel.StreamHandler {
      override fun onListen (listener: Any?, eventSink: EventChannel.EventSink) {logSink = eventSink}
      override fun onCancel (listener: Any?) {logSink = null}})
    logC = chan}
}
