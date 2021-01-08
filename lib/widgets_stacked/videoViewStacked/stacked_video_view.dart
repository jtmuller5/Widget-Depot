import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

class StackedVideoView extends StatelessWidget {
  final bool showFull;

  const StackedVideoView({Key key, this.showFull = false})
      : super(
            key:
                key); // Should we scale the viewer down so everything can be seen

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StackedVideoViewModel>.reactive(
      viewModelBuilder: () => StackedVideoViewModel(),
      onModelReady: (model) {
        model.initialize(
            'https://firebasestorage.googleapis.com/v0/b/arch-road-development.appspot.com/o/postVideos%2F286455068112192002_0?alt=media&token=ad10a50c-f00c-4fed-90d4-2e48f7e02fcd');
      },
      builder: (context, model, child) {
        // If we want to show the full video, we need to scale it to fit the longest side
        if (showFull) {
          bool wideVideo = model.videoPlayerController.value.size.width >
              model.videoPlayerController.value.size.height;

          if (wideVideo) {
            return Row(
              children: [
                Expanded(
                    child: AspectRatio(
                  aspectRatio: model.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(model.videoPlayerController),
                ))
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                    child: AspectRatio(
                  aspectRatio: model.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(model.videoPlayerController),
                ))
              ],
            );
          }
        }

        // Else just show a portion of the video viewport
        else {
          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: model.videoPlayerController.value.size?.height ?? 0,
              width: model.videoPlayerController.value.size?.width ?? 0,
              child: VideoPlayer(model.videoPlayerController),
            ),
          );
        }
      },
    );
  }
}
