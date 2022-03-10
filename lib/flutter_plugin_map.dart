
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterPluginMap {
  static const MethodChannel _channel = MethodChannel('flutter_plugin_map');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class AmapView extends StatelessWidget {

  final AmapConfig config;

  static const MethodChannel _channel = MethodChannel('flutter_plugin_map');

  const AmapView({Key? key, required this.config}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType:"com.example.flutter_plugin_map/mapview",
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: config.toMap(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType:"AMapView",
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: config.toMap(),
      );
    } else {
      return Container();
    }
  }

  Future<Future> addMarker(MarkerOption options) async {
    return _channel.invokeMethod("addMarkers", options.toMap());
  }
}

class AmapConfig {
  int interval;
  double zoomLevel;
  List<MarkerOption>? options;  // 位置
  bool showStartAndEndIcon;  // 是否显示装货地，卸货地图标
  bool showWayPointsIcon;    // 是否显示途经点图标
  double lineWidth;          // 路径宽度

  AmapConfig({
    this.interval = 1000,
    this.zoomLevel = 28.0,
    this.showStartAndEndIcon = true,
    this.showWayPointsIcon = true,
    this.lineWidth = 8,
    this.options
  });

  Map toMap() {
    Map map = {};
    map['interval'] = interval;
    map['zoomLevel'] = zoomLevel;
    map['options'] = options?.map((e) => e.toMap()).toList();
    map['showStartAndEndIcon'] = showStartAndEndIcon;
    map['showWayPointsIcon'] = showWayPointsIcon;
    map['lineWidth'] = lineWidth;
   
    return map;
  }
}

class MarkerOption {
  double latitude;
  double longitude;
  String title;

  MarkerOption({required this.latitude, required this.longitude, required this.title});

  Map toMap() {
    Map map = {};
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['title'] = title;
    return map;
  }
}


