import 'package:flutter/material.dart';
import 'package:widget_depot/screens/showcase.dart';
import 'package:widget_depot/widgets_stacked/cameraViewStacked/stacked_camera_view.dart';

class CameraScreen extends StatelessWidget {

  static const String id = 'Camera Screen';

  @override
  Widget build(BuildContext context) {
    return Showcase(StackedCameraView(), 'Camera');
  }
}