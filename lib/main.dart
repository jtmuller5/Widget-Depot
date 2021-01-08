import 'package:flutter/material.dart';
import 'package:widget_depot/screens/placeholder_screen.dart';
import 'package:widget_depot/screens/widgetScreens/camera_screen.dart';
import 'package:widget_depot/screens/widgetScreens/video_screen.dart';
import 'package:widget_depot/widget_depot_view.dart';

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
        CameraScreen.id: (context) => CameraScreen(),
        PlaceholderScreen.id: (context) => PlaceholderScreen()
      },
    );
  }
}
