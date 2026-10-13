package gr.agrocult.agrocult

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // App-private paths for the Dart side (lib/core/db/database_location.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gr.agrocult/app_paths")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "databaseDirectory" -> {
                        val dir = applicationContext.getDatabasePath("agrocult.sqlite").parentFile
                        if (dir == null) {
                            result.error("no_directory", "No database directory", null)
                        } else {
                            dir.mkdirs()
                            result.success(dir.absolutePath)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
