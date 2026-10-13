import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerAppPathsChannel(engineBridge.pluginRegistry)
  }

  // App-private paths for the Dart side (lib/core/db/database_location.dart).
  private func registerAppPathsChannel(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "AgrocultAppPaths") else { return }
    let channel = FlutterMethodChannel(
      name: "gr.agrocult/app_paths", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "databaseDirectory":
        do {
          let dir = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
          result(dir.path)
        } catch {
          result(FlutterError(code: "no_directory", message: "No database directory", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
