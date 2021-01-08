import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {

  final String videoUrl;
  final bool showFull;

  const VideoViewer({Key key, this.videoUrl, this.showFull}) : super(key: key);

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(
      widget.videoUrl,
    );
    videoPlayerController.initialize().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController.value.initialized) {
      // If we want to show the full video, we need to scale it to fit the longest side
      if (widget.showFull) {
        bool wideVideo = videoPlayerController.value.size.width >
            videoPlayerController.value.size.height;

        if (wideVideo) {
          return Row(
            children: [
              Expanded(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
                  ))
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
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
            height: videoPlayerController.value.size?.height ?? 0,
            width: videoPlayerController.value.size?.width ?? 0,
            child: VideoPlayer(videoPlayerController),
          ),
        );
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
