import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view_model.dart';

/// (1) Use the WidgetsBindingObserver to get the VideoThumbnail's size
/// after it is laid out
class VideoThumbnail extends ViewModelWidget<StackedVideoViewModel> with WidgetsBindingObserver{

  @override
  Widget build(BuildContext context, StackedVideoViewModel model) {

    /// (3) Get the size of the widget after it is rendered on screen
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
            print('wide thumbnail');
            return Row(
              /// (2) Mark the final video thumbnail with a GlobalObject Key
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
            print('tall thumbnail');
            return Column(
              /// (2) Mark the final video thumbnail with a GlobalObject Key
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
          print('fitted thumbnail');
          return SizedBox.expand(
            child: FittedBox(
              /// (2) Mark the final video thumbnail with a GlobalObject Key
              key: model.thumbnailKey,
              fit: BoxFit.cover,
              alignment: Alignment(model.x, model.y),
              child: SizedBox(
                height:
                model.videoPlayerController.value.size?.height ?? 0,
                width: model.videoPlayerController.value.size?.width ?? 0,
                child: VideoPlayer(model.videoPlayerController),
              ),
            ),
          );
        }
      },
    );
  }
}