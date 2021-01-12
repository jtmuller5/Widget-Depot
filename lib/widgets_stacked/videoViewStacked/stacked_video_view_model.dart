import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class StackedVideoViewModel extends BaseViewModel {

  // Input Properties
  VideoPlayerController videoPlayerController;
  bool showFull;
  double x; // X alignment of FittedBox
  double y; // Y alignment of FittedBox

  // Local Properties
  bool gotThumbnailSize = false;
  double thumbnailWidth;
  double thumbnailHeight;

  /// Keys
  GlobalKey thumbnailKey = GlobalObjectKey('video_thumbnail');

  void initialize(String videoUrl, bool full,double inx, double iny) {
    showFull = full;
    x = inx;
    y = iny;

    videoPlayerController = VideoPlayerController.network(videoUrl);
    videoPlayerController.initialize().then((value) {
      videoPlayerController.setLooping(true);
      notifyListeners();
    });
  }

  void playVideo(){
    videoPlayerController.play();
    notifyListeners();
  }

  void pauseVideo(){
    videoPlayerController.pause();
    notifyListeners();
  }

  void getVideoSize(){

    RenderBox render = thumbnailKey.currentContext.findRenderObject() as RenderBox;
    //Constraints constraints = render.constraints;
    thumbnailWidth = render.size.width;
    thumbnailHeight = render.size.height;

    print("height: ${thumbnailHeight.toString()}");
    print("width: ${thumbnailWidth.toString()}");

    gotThumbnailSize = true;

    notifyListeners();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
