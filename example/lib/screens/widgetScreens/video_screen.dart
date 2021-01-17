import 'package:flutter/material.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view.dart';

import '../showcase.dart';

class VideoScreen extends StatelessWidget {
  static const String id = 'Video Screen';

  @override
  Widget build(BuildContext context) {
    return Showcase(
        StackedVideoView(
          showRemaining: true,
          canPlay: true,
          showElapsed: true,
          showFull: true,
        ),
        'Video Player');
  }
}
