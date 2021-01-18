import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../object_detector_view_model.dart';

class CameraPreviewCustom extends ViewModelWidget<ObjectDetectorViewModel> {
  @override
  Widget build(BuildContext context, model) {
    if (model.cameraController == null || !model.cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      final size = MediaQuery.of(context).size;
      final deviceRatio = size.width / size.height;

      return
        //CameraPreview(model.cameraController);

        Transform.scale(
          scale: model.cameraController.value.aspectRatio / deviceRatio,
          child: AspectRatio(
              aspectRatio: model.cameraController.value.aspectRatio,
              child: CameraPreview(model.cameraController)),
        );
    }
  }
}