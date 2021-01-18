import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

class VideoPlayback extends ViewModelWidget<StackedVideoViewModel> {

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {
    return PopupMenuButton<double>(
      initialValue: model.videoPlayerController.value.playbackSpeed,
      tooltip: 'Playback speed',
      onSelected: (speed) {
        model.videoPlayerController.setPlaybackSpeed(speed);
      },
      itemBuilder: (context) {
        return [
          for (final speed in _examplePlaybackRates)
            PopupMenuItem(
              value: speed,
              child: Text('${speed}x'),
            )
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          // Using less vertical padding as the text is also longer
          // horizontally, so it feels like it would need more spacing
          // horizontally (matching the aspect ratio of the video).
          vertical: 12,
          horizontal: 16,
        ),
        child: Text('${model.videoPlayerController.value.playbackSpeed}x'),
      ),
    );
  }

}