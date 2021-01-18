import 'package:flutter/material.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view.dart';

import '../showcase.dart';

class VideoFrameScreen extends StatelessWidget {
  static const String id = 'Video Frame Screen';

  @override
  Widget build(BuildContext context) {
    return Showcase(
        StackedVideoView(
          showRemaining: false,
          canPlay: false,
          showElapsed: false,
          showFull: true,
          allowSelection: true,
        ),
        'Video Player');
  }
}