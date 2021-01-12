import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

class ControlOverlay extends ViewModelWidget<StackedVideoViewModel> {
  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {
    return Container(
      height: model.thumbnailHeight,
      width: model.thumbnailWidth,
      child: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: model.videoPlayerController.value.isPlaying
                ? SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: model.thumbnailHeight/4,
                      ),
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () {
              model.videoPlayerController.value.isPlaying
                  ? model.pauseVideo()
                  : model.playVideo();
            },
          ),
        ],
      ),
    );
  }
}
