import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

class VideoThumbnail extends ViewModelWidget<StackedVideoViewModel> with WidgetsBindingObserver{

  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          if(!model.gotThumbnailSize)model.getVideoSize();
    });

    return Builder(
      builder: (context) {
        // If we want to show the full video, we need to scale it to fit the longest side
        if (model.showFull) {
          bool wideVideo =
              model.videoPlayerController.value.size.width >
                  model.videoPlayerController.value.size.height;

          if (wideVideo) {
            return Row(
              key: model.thumbnailKey,
              children: [
                Expanded(
                    child: AspectRatio(
                      aspectRatio:
                      model.videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(model.videoPlayerController),
                    ))
              ],
            );
          } else {
            return Column(
              key: model.thumbnailKey,
              children: [
                Expanded(
                    child: AspectRatio(
                      aspectRatio:
                      model.videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(model.videoPlayerController),
                    ))
              ],
            );
          }
        }

        // Else just show a portion of the video viewport
        else {
          return FittedBox(
            key: model.thumbnailKey,
            fit: BoxFit.cover,
            alignment: Alignment(model.x, model.y),
            child: SizedBox(
              height:
              model.videoPlayerController.value.size?.height ?? 0,
              width: model.videoPlayerController.value.size?.width ?? 0,
              child: VideoPlayer(model.videoPlayerController),
            ),
          );
        }
      },
    );
  }
}