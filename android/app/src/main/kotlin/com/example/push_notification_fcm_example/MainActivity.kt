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
import androidx.appcompat.app.AppCompatActivity
import com.example.push_notification_fcm_example // Flutter에서 생성한 MainActivity에 대한 패키지 경로로 수정


class MainActivity: FlutterActivity() {
//    private val TAG = "MainActivity"
    private val CHANNEL = "Channel Name"

    val webView = findViewById<WebView>(R.id.webView)
    // 공통 설정
    webView.settings.run {
        javaScriptEnabled = true
        javaScriptCanOpenWindowsAutomatically = true
        setSupportMultipleWindows(true)
    }

    webView.webViewClient = object: WebViewClient() {

        override fun shouldOverrideUrlLoading(view: WebView,request: WebResourceRequest): Boolean {
            Log.d(TAG, request.url.toString())

            if (request.url.scheme == "intent") {
                try {
                    // Intent 생성
                    val intent = Intent.parseUri(request.url.toString(), Intent.URI_INTENT_SCHEME)

                    // 실행 가능한 앱이 있으면 앱 실행
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        Log.d(TAG, "ACTIVITY: ${intent.`package`}")
                        return true
                    }

                    // Fallback URL이 있으면 현재 웹뷰에 로딩
                    val fallbackUrl = intent.getStringExtra("http://43.200.254.50:80/profile")
                    if (fallbackUrl != null) {
                        view.loadUrl(fallbackUrl)
                        Log.d(TAG, "FALLBACK: $fallbackUrl")
                        return true
                    }

                    Log.e(TAG, "Could not parse anythings")

                } catch (e: URISyntaxException) {
                    Log.e(TAG, "Invalid intent request", e)
                }
            }

            // 나머지 서비스 로직 구현

            return false
        }
    }
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_main)
//
//        // 공통 설정
//        val webView = findViewById<WebView>(R.id.webView)
//        webView.settings.javaScriptEnabled = true
//        webView.settings.javaScriptCanOpenWindowsAutomatically = true
//        webView.settings.setSupportMultipleWindows(true)
//
//        webView.webViewClient = object : WebViewClient() {
//            override fun shouldOverrideUrlLoading(
//                    view: WebView,
//                    request: WebResourceRequest
//            ): Boolean {
//                Log.d(TAG, request.url.toString())
//
//                if (request.url.scheme == "intent") {
//                    try {
//                        val intent = Intent.parseUri(request.url.toString(), Intent.URI_INTENT_SCHEME)
//                        if (intent.resolveActivity(packageManager) != null) {
//                            startActivity(intent)
//                            Log.d(TAG, "ACTIVITY: ${intent.`package`}")
//                            return true
//                        }
//                        val fallbackUrl = intent.getStringExtra("http://43.200.254.50:80/profile")
//                        if (fallbackUrl != null) {
//                            view.loadUrl(fallbackUrl)
//                            Log.d(TAG, "FALLBACK: $fallbackUrl")
//                            return true
//                        }
//                        Log.e(TAG, "Could not parse anything")
//                    } catch (e: URISyntaxException) {
//                        Log.e(TAG, "Invalid intent request", e)
//                    }
//                }
//
//                // 나머지 서비스 로직 구현
//
//                return false
//            }
//        }
//
//        // 웹뷰 로딩 등 추가 설정
//    }
//    // 공통 설정
//    webView.settings.run {
//        javaScriptEnabled = true
//        javaScriptCanOpenWindowsAutomatically = true
//        setSupportMultipleWindows(true)
//    }
//
//    webView.webChromeClient = object: WebChromeClient() {
//
//        /// ---------- 팝업 열기 ----------
//        /// - 카카오 JavaScript SDK의 로그인 기능은 popup을 이용합니다.
//        /// - window.open() 호출 시 별도 팝업 webview가 생성되어야 합니다.
//        ///
//        override fun onCreateWindow(
//                view: WebView,
//                isDialog: Boolean,
//                isUserGesture: Boolean,
//                resultMsg: Message
//        ): Boolean {
//
//            // 웹뷰 만들기
//            var childWebView = WebView(view.context)
//
//            // 부모 웹뷰와 동일하게 웹뷰 설정
//            childWebView.run {
//                settings.run {
//                    javaScriptEnabled = true
//                    javaScriptCanOpenWindowsAutomatically = true
//                    setSupportMultipleWindows(true)
//                }
//                layoutParams = view.layoutParams
//                webViewClient = view.webViewClient
//                webChromeClient = view.webChromeClient
//            }
//
//            // 화면에 추가하기
//            webViewLayout.addView(childWebView)
//            // TODO: 화면 추가 이외에 onBackPressed() 와 같이
//            //       사용자의 내비게이션 액션 처리를 위해
//            //       별도 웹뷰 관리를 권장함
//            //   ex) childWebViewList.add(childWebView)
//
//            // 웹뷰 간 연동
//            val transport = resultMsg.obj as WebView.WebViewTransport
//            transport.webView = childWebView
//            resultMsg.sendToTarget()
//
//            return true
//        }
//
//        /// ---------- 팝업 닫기 ----------
//        /// - window.close()가 호출되면 앞에서 생성한 팝업 webview를 닫아야 합니다.
//        ///
//        override fun onCloseWindow(window: WebView) {
//            super.onCloseWindow(window)
//
//            // 화면에서 제거하기
//            webViewLayout.removeView(window)
//            // TODO: 화면 제거 이외에 onBackPressed() 와 같이
//            //       사용자의 내비게이션 액션 처리를 위해
//            //       별도 웹뷰 array 관리를 권장함
//            //   ex) childWebViewList.remove(childWebView)
//        }
//    }
//    private val CHANNEL = "Channel Name"
//
//    //MethodChannel 구현
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if(call.method == "getAppUrl") {                // Intent:// 스키마를 통한 URL파싱
//                try {
//                    val url: String? = call.argument("url")
//
//                    if(url == null) {
//                        result.error("9999", "URL PARAMETER IS NULL", null)
//                    } else {
//                        Log.i("[getAppUrl] url", url)
//                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
//                        result.success(intent.dataString)
//                    }
//                } catch (e: URISyntaxException) {
//                    result.notImplemented()
//                } catch (e: ActivityNotFoundException) {
//                    result.notImplemented()
//                }
//            } else if(call.method == "getMarketUrl") {          // 들어온 URL을 통해 package 명 및 market 다운로드 주소 반환
//                try {
//                    val url: String? = call.argument("url")
//                    if(url == null) {
//                        result.error("9999", "URL PARAMETER IS NULL", null)
//                    } else {
//                        Log.i("[getMarketUrl] url", url)
//                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
//                        val scheme = intent.scheme
//                        val packageName = intent.getPackage()
//                        if (packageName != null) {
//                            result.success("market://details?id=$packageName")
//                        }
//                        result.notImplemented()
//                    }
//                } catch (e: URISyntaxException) {
//                    result.notImplemented()
//                } catch (e: ActivityNotFoundException) {
//                    result.notImplemented()
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
}
