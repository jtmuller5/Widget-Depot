import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

/// Mixin used by any ViewModel that displays a Video thumbnail
mixin VideoThumbnailMixin on BaseViewModel{
  // Local Properties
  bool gotThumbnailSize = false;
  double thumbnailWidth = 300;
  double thumbnailHeight = 200;

  double x; // X alignment of FittedBox
  double y; // Y alignment of FittedBox

  VideoPlayerController videoPlayerController;
  bool showFull;

  /// Keys
  GlobalKey thumbnailKey = GlobalObjectKey('video_thumbnail');

  void initializeVideo(String videoUrl, bool showRemaining){
    videoPlayerController = VideoPlayerController.network(videoUrl);
    videoPlayerController.initialize().then((value) {
      videoPlayerController.setLooping(true);
      notifyListeners();
    });

    videoPlayerController.addListener(() {
      if(showRemaining && videoPlayerController.value.isPlaying) {
        print('updating vp');
        notifyListeners();
      }
    });
  }

  /// Get the width and height dimensions of the Video Thumbnail
  void getVideoSize(){

    RenderBox render = thumbnailKey.currentContext.findRenderObject() as RenderBox;

    thumbnailWidth = render.size.width;
    thumbnailHeight = render.size.height;

    gotThumbnailSize = true;

    notifyListeners();
  }
}