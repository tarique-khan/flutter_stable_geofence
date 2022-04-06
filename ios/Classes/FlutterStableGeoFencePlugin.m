#import "FlutterStableGeoFencePlugin.h"
#if __has_include(<flutter_stable_geo_fence/flutter_stable_geo_fence-Swift.h>)
#import <flutter_stable_geo_fence/flutter_stable_geo_fence-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_stable_geo_fence-Swift.h"
#endif

@implementation FlutterStableGeoFencePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterStableGeoFencePlugin registerWithRegistrar:registrar];
}
@end
