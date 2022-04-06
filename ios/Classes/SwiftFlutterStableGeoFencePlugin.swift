import Flutter
import UIKit

public class SwiftFlutterStableGeoFencePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_stable_geo_fence", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterStableGeoFencePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
