// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:flutter/services.dart';
// import 'package:flutter_plugin_map/flutter_plugin_map.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String _platformVersion = 'Unknown';
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion =
//           await FlutterPluginMap.platformVersion ?? 'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Text('Running on: $_platformVersion\n'),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_plugin_map/flutter_plugin_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late AmapView amapView;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    amapView =  AmapView(
      config: AmapConfig(
          zoomLevel: 3,
          options: [MarkerOption(latitude: 39.91667, longitude: 116.41667, title: '装货地'),
            MarkerOption(latitude: 38.43, longitude: 115.83, title: "suning"),
            // MarkerOption(latitude: 38.00109, longitude: 115.55993, title: "suning"),
            // MarkerOption(latitude: 37.45, longitude: 116.37, title: "suning"),
            // MarkerOption(latitude: 37.03, longitude: 115.89, title: "suning"),
            // MarkerOption(latitude: 37.17, longitude: 116.43, title: "suning"),
            // MarkerOption(latitude: 36.93, longitude: 116.63, title: "suning"),
            // MarkerOption(latitude: 35.38, longitude: 116.20, title: "suning"),
            MarkerOption(latitude: 34.26, longitude: 117.2, title: "suning"),
            MarkerOption(latitude: 34.50000, longitude: 121.43333, title: '卸货地'),
          ],
       ),
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: amapView
        ),
        floatingActionButton: FloatingActionButton(
          child: const Text('marker'),
          onPressed: () async {
            await amapView.addMarker(MarkerOption(latitude: 34.341568, longitude: 108.940174, title: "标记"));
            // debugPrint(msg);
          },
        ),
      ),
    );
  }
}


