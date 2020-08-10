package com.komodoplatform.atomicdex;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.content.Context.NOTIFICATION_SERVICE;

public class MainActivity extends FlutterFragmentActivity {
  private EventChannel logC;
  private EventChannel.EventSink logSink;
  boolean notifications = true;

  private void createNotificationChannel() {
    if (!notifications) return;  // WIP

    // TBD: Use AndroidX to create the channel.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationChannel channel = new NotificationChannel("com.komodoplatform.atomicdex/notification", "NotificationChannel name", NotificationManager.IMPORTANCE_DEFAULT);
      channel.setDescription("NotificationChannel description");

      // Workaround the Flutter classpath issues (unavailability of the `android.support.v4.app.FragmentActivity` on the classpath).
      logSink.success("createNotificationChannel] Casting `this` to `Activity`..");
      Activity activity = (Activity) (Object) this;

      NotificationManager notificationManager = (NotificationManager) activity.getSystemService(NOTIFICATION_SERVICE);
      notificationManager.createNotificationChannel(channel);
      logSink.success("createNotificationChannel] done createNotificationChannel");
    }
  }

  void createNotification(String title, String text) {
    if (!notifications) return;  // WIP

    Activity activity = (Activity) (Object) this;
    NotificationCompat.Builder builder = new NotificationCompat.Builder(activity, "com.komodoplatform.atomicdex/notification")
      .setSmallIcon(R.mipmap.launcher_icon)
      .setContentTitle(title)
      .setContentText(text)
      .setPriority(NotificationCompat.PRIORITY_DEFAULT);

    NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(activity);
    // notificationId is a unique int for each notification that you must define
    int notificationId = 1;
    notificationManagerCompat.notify(notificationId, builder.build());
  }

  private void nativeC() {
    BinaryMessenger bm = getFlutterEngine().getDartExecutor().getBinaryMessenger();
    // https://flutter.dev/docs/development/platform-integration/platform-channels?tab=android-channel-kotlin-tab#step-3-add-an-android-platform-specific-implementation
    new MethodChannel(bm, "com.komodoplatform.atomicdex/nativeC").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("ping")) {  // Allows us to test the channel.
          // Example using the `logSink`:
          //
          //     logSink?.success ("ping] Logging from MainActivity.kt; BUILD_TIME: " + BuildConfig.BUILD_TIME)

          result.success("pong");
        } else if (call.method.equals("show_notification")) {
          createNotification(call.argument("title"), call.argument("text"));
          result.success(null);
        } else if (call.method.equals("BUILD_TIME")) {
          // NB: If Kotlin is missing the “BUILD_TIME” then use “flutter build apk --debug”
          // to generate the “komodoDEX/build/app/intermediates/javac/debug/classes/com/komodoplatform/atomicdex/BuildConfig.class”.
          result.success(BuildConfig.BUILD_TIME);
        } else {
          result.notImplemented();
        }
      }
    });
  }

  private void logC() {
    // https://blog.testfairy.com/listeners-with-eventchannel-in-flutter/
    // https://api.flutter.dev/javadoc/index.html?io/flutter/plugin/common/EventChannel.html
    BinaryMessenger bm = getFlutterEngine().getDartExecutor().getBinaryMessenger();
    EventChannel chan = new EventChannel(bm, "AtomicDEX/logC");

    chan.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        logSink = eventSink;
        createNotificationChannel();
      }

      @Override
      public void onCancel(Object arguments) {
        logSink = null;
      }
    });

    logC = chan;
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    nativeC();
    logC();
  }
}
