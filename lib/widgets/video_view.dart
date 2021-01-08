import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {

  final String videoUrl;

  const VideoViewer({Key key, this.videoUrl}) : super(key: key);

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
      return SizedBox.expand(
          child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                  height: videoPlayerController.value.size?.height ?? 0,
                  width: videoPlayerController.value.size?.width ?? 0,
                  child: VideoPlayer(videoPlayerController))));
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
