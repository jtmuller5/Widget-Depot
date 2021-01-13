import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../stacked_video_view_model.dart';

class VideoTimeElapsed extends ViewModelWidget<StackedVideoViewModel> {
  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {
    return Container(
      padding: EdgeInsets.only(bottom: 8, left: 8),
      height: model.thumbnailHeight,
      width: model.thumbnailWidth,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          child: Text(
            model.timeElapsedString,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}