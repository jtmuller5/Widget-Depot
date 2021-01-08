import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/cameraViewStacked/stacked_camera_view_model.dart';

class StackedCameraView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StackedCameraViewModel>.reactive(
      viewModelBuilder: () => StackedCameraViewModel(),
      onModelReady: (model) {
        // model.initialize();
      },
      builder: (context, model, child) {
        return Container();
      },
    );
  }
}