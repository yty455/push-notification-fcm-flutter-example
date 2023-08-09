package com.example.push_notification_fcm_example

import android.content.ActivityNotFoundException
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URISyntaxException
import android.net.Uri
import android.os.Bundle


class MainActivity: FlutterActivity() {
    private var CHANNEL = "intent"
    private var methodChannel: MethodChannel? = null

//    @SuppressLint("NewApi")
    @Suppress
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL);
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "launchKakaoTalk") {
                var url = call.argument<String>("url");
                val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
                // 실행 가능한 앱이 있으면 앱 실행
                if (intent.resolveActivity(packageManager) != null) {
                    val existPackage = packageManager.getLaunchIntentForPackage("" + intent.getPackage());
                    startActivity(intent)
                    result.success(null);
                } else {
                    // Fallback URL이 있으면 현재 웹뷰에 로딩
                    val fallbackUrl = intent.getStringExtra("http://43.200.254.50/login")
                    if (fallbackUrl != null) {
                        result.success(fallbackUrl);
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
