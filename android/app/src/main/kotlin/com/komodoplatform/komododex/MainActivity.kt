package com.komodoplatform.atomicdex

import android.os.Build
import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.ViewTreeObserver
import android.view.WindowManager
import androidx.annotation.RequiresApi



class MainActivity: FlutterActivity() {
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

  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun changeStatuBar() {
    window.statusBarColor = 0x00000000
  }

}
