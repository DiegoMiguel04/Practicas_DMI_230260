package com.example.toktik_app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "toktik/app_icon")
            .setMethodCallHandler { call, result ->
                if (call.method != "setSeason") { result.notImplemented(); return@setMethodCallHandler }
                val alias = when (call.arguments as? String) {
                    "normal" -> "DefaultLauncher"
                    "octubre" -> "OctoberLauncher"
                    "diciembre" -> "DecemberLauncher"
                    "febrero" -> "FebruaryLauncher"
                    else -> { result.error("invalid_season", "Unknown season", null); return@setMethodCallHandler }
                }
                listOf("OctoberLauncher", "DecemberLauncher", "FebruaryLauncher", "DefaultLauncher").forEach { name ->
                    packageManager.setComponentEnabledSetting(
                        ComponentName(this, "$packageName.$name"),
                        if (name == alias) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP,
                    )
                }
                result.success(null)
            }
    }
}

class OctoberLauncher : MainActivity()
class DecemberLauncher : MainActivity()
class FebruaryLauncher : MainActivity()
