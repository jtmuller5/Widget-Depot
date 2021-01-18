import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

/// Widget to allow video frame selection using a draggable handle
class VideoFrameSelector extends ViewModelWidget<StackedVideoViewModel> {
  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {
    return Container(
      height: model.thumbnailHeight,
      width: model.thumbnailWidth,
      child: Stack(
        children: <Widget>[
          Slider(value: null,
              onChanged: null)
        ],
      ),
    );
  }
}