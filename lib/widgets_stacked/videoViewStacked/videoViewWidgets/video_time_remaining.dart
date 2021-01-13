import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

class VideoTimeRemaining extends ViewModelWidget<StackedVideoViewModel> {
  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {
    return Container(
      padding: EdgeInsets.only(top: 8, right: 8),
      height: model.thumbnailHeight,
      width: model.thumbnailWidth,
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          child: Text(
            model.timeRemainingString,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
