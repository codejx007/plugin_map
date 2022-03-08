#import "FlutterPluginMapPlugin.h"
#if __has_include(<flutter_plugin_map/flutter_plugin_map-Swift.h>)
#import <flutter_plugin_map/flutter_plugin_map-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_plugin_map-Swift.h"
#endif

@implementation FlutterPluginMapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPluginMapPlugin registerWithRegistrar:registrar];
}
@end
