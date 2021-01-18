import 'package:example/screens/widgetScreens/object_detector_screen.dart';
import 'package:example/screens/widgetScreens/video_frame_screen.dart';
import 'package:flutter/material.dart';

import 'screens/placeholder_screen.dart';
import 'screens/widgetScreens/camera_screen.dart';
import 'screens/widgetScreens/video_screen.dart';
import 'widget_depot_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Depot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WidgetDepotView(),
      routes: {
        WidgetDepotView.id: (context) => WidgetDepotView(),
        VideoScreen.id: (context) => VideoScreen(),
        VideoFrameScreen.id: (context) => VideoFrameScreen(),
        ObjectDetectorScreen.id: (context) => ObjectDetectorScreen(),
        CameraScreen.id: (context) => CameraScreen(),
        PlaceholderScreen.id: (context) => PlaceholderScreen()
      },
    );
  }
}