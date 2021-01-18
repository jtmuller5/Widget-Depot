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
        model.initialize(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            context: context);
      },
      builder: (context, model, child) {
        return Scaffold(
            body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CameraPreviewCustom()],
        ));
      },
    );
  }
}
