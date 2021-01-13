import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class StackedVideoViewModel extends BaseViewModel {

  // Input Properties
  VideoPlayerController videoPlayerController;
  bool showFull;
  bool showRemaining;
  bool showElapsed;
  double x; // X alignment of FittedBox
  double y; // Y alignment of FittedBox

  // Local Properties
  bool gotThumbnailSize = false;
  double thumbnailWidth = 300;
  double thumbnailHeight = 200;

  /// Keys
  GlobalKey thumbnailKey = GlobalObjectKey('video_thumbnail');

  /// Getters
  Duration get totalVideoLength{
    return videoPlayerController.value.duration;
  }

  String get totalVideoLengthString{
    return _printDuration(totalVideoLength);
  }

  Duration get timeRemaining {
    Duration current = videoPlayerController.value.position;
    int millis = totalVideoLength.inMilliseconds - current.inMilliseconds;
    return Duration(milliseconds: millis);
  }

  String get timeRemainingString {
    return _printDuration( timeRemaining);
  }

  Duration get timeElapsed {
    return videoPlayerController.value.position;
  }

  String get timeElapsedString {
    return _printDuration(timeElapsed);
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void initialize(String videoUrl, bool full,double inx, double iny, bool remaining, bool elapse) {
    showFull = full;
    showRemaining = remaining;
    showElapsed = elapse;
    x = inx;
    y = iny;

    videoPlayerController = VideoPlayerController.network(videoUrl);
    videoPlayerController.initialize().then((value) {
      videoPlayerController.setLooping(true);
      notifyListeners();
    });

    videoPlayerController.addListener(() {
      if(remaining && videoPlayerController.value.isPlaying) {
        print('updating vp');
        notifyListeners();
      }
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

  /// Get the width and height dimensions of the Video Thumbnail
  void getVideoSize(){

    RenderBox render = thumbnailKey.currentContext.findRenderObject() as RenderBox;

    thumbnailWidth = render.size.width;
    thumbnailHeight = render.size.height;

    gotThumbnailSize = true;

    notifyListeners();
  }

  /// Dispose the VideoPlayerController
  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
