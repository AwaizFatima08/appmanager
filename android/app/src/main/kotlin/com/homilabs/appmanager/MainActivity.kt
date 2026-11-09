package com.homilabs.appmanager

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var channel: AppManagerChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = AppManagerChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.dispose()
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    @Deprecated("FlutterActivity is not a ComponentActivity, so this is the result hook it has.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (channel?.onActivityResult(requestCode) != true) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
