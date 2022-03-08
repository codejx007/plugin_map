//
//  AmapViewFactory.swift
//  flutter_plugin_map
//
//  Created by 孙红 on 2022/3/8.
//

import Foundation

public class AmapViewFactory: NSObject,FlutterPlatformViewFactory {
    var messenger: FlutterBinaryMessenger!
        
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AmapView(messenger: messenger, params: args as! Dictionary<String, Any?>);
    }
        
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
        
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
