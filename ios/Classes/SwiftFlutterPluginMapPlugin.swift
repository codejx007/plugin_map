import Flutter
import UIKit

public class SwiftFlutterPluginMapPlugin: NSObject, FlutterPlugin {
    
  private static var factory: AmapViewFactory?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_plugin_map", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPluginMapPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
    AMapServices.shared().apiKey = "17159445807cc9dc9a5bb02991411527"
    factory = AmapViewFactory(messenger: registrar.messenger())
    registrar.register(factory!, withId: "AMapView")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

}
