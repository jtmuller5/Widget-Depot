import 'package:flutter/material.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/object_detector_view.dart';

import '../showcase.dart';

class ObjectDetectorScreen extends StatelessWidget {
  static const String id = 'Object Detector Screen';

  @override
  Widget build(BuildContext context) {
    return Showcase(
        ObjectDetectorView(),
        'Object Detector');
  }
}