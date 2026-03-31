package com.mrdarksidetm.wallet

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.mrdarksidetm.wallet/app_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isUniversalBuild") {
                result.success(isUniversalBuild())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isUniversalBuild(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // We removed "context." here because MainActivity is already a Context!
                val splitDirs = applicationInfo.splitSourceDirs
                splitDirs == null || splitDirs.isEmpty()
            } else {
                true
            }
        } catch (e: Exception) {
            true
        }
    }
}
