package com.smooth55dev.fcm

import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import app.tauri.plugin.fcm.FcmPlugin
import io.tauri.app.TauriActivity

class MainActivity : TauriActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Register the FCM plugin
        registerPlugin(FcmPlugin(this))
        
        // Optimize WebView performance
        try {
            val webView = findViewById<WebView>(android.R.id.webview)
            if (webView != null) {
                val settings = webView.settings
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = true
                settings.cacheMode = WebSettings.LOAD_DEFAULT
                settings.setRenderPriority(WebSettings.RenderPriority.HIGH)
                settings.setAppCacheEnabled(false)
            }
        } catch (e: Exception) {
            // Ignore if webview is not available
        }
    }
}
