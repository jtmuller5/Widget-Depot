import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/objectDetectorViewWidgets/camera_preview_custom.dart';

import 'object_detector_view_model.dart';

class ObjectDetectorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObjectDetectorViewModel>.reactive(
      viewModelBuilder: () => ObjectDetectorViewModel(),
      onModelReady: (model) {
        // model.initialize();
      },
      builder: (context, model, child) {
        return Scaffold(
            body: Column(
              children: [
                CameraPreviewCustom()
              ],
            )
        );
      },
    );
  }
}