import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/videoViewWidgets/video_control_overlay.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/videoViewWidgets/video_thumbnail.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/videoViewWidgets/video_time_elapsed.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/videoViewWidgets/video_time_remaining.dart';

/// Shows just the Video thumbnail
class StackedVideoView extends StatelessWidget {
  /// The video URL you want to display
  final String videoURL;

  /// Should the entire video be visible?
  final bool showFull;

  /// Can the video be played? This toggles video overlays and controls
  final bool canPlay;

  /// Show the amount of time remaining in the video
  final bool showRemaining;

  /// Show the amount of time elapsed in the video
  final bool showElapsed;

  /// X alignment of FittedBox
  final double x;

  /// Y alignment of FittedBox
  final double y;

  const StackedVideoView({
    Key key,
    this.videoURL = 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
    this.showFull = false,
    this.canPlay = false,
    this.showRemaining = false,
    this.showElapsed = false,
    this.x = 0,
    this.y = 0,
  }) : super(
            key:
                key); // Should we scale the viewer down so everything can be seen

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StackedVideoViewModel>.reactive(
      viewModelBuilder: () => StackedVideoViewModel(),
      onModelReady: (model) {
        model.initialize(
            videoURL,
            showFull,
            x,
            y,
            showRemaining,
        showElapsed);
      },
      builder: (context, model, child) {
        if (model.videoPlayerController.value.initialized) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoThumbnail(),
              if (canPlay) VideoControlOverlay(),
              if (canPlay && showRemaining) VideoTimeRemaining(),
              if (canPlay && showElapsed) VideoTimeElapsed(),
              if (canPlay)
                VideoProgressIndicator(
                  model.videoPlayerController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                      backgroundColor: Colors.green,
                      bufferedColor: Colors.yellow,
                      playedColor: Colors.purple),
                ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
