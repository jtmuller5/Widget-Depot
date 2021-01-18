import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:widget_depot/widgets_stacked/mixins/video_thumbnail_mixin.dart';

class StackedVideoViewModel extends BaseViewModel {
  // Input properties
  VideoPlayerController videoPlayerController;
  bool showFull;
  bool showRemaining;
  bool showElapsed;
  bool allowSelection;
  double x; // X alignment of FittedBox
  double y; // Y alignment of FittedBox

  /// Local properties
  bool loading = false;

  // Local Properties
  bool gotThumbnailSize = false;
  double thumbnailWidth = 300;
  double thumbnailHeight = 200;

  /// Keys
  GlobalKey thumbnailKey = GlobalObjectKey('video_thumbnail');

  /// Getters
  Duration get totalVideoLength {
    return videoPlayerController.value.duration;
  }

  String get totalVideoLengthString {
    return _printDuration(totalVideoLength);
  }

  Duration get timeRemaining {
    Duration current = videoPlayerController.value.position;
    int millis = totalVideoLength.inMilliseconds - current.inMilliseconds;
    return Duration(milliseconds: millis);
  }

  String get timeRemainingString {
    return _printDuration(timeRemaining);
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

  void initialize(
    String videoUrl,
    bool full,
    double inx,
    double iny,
    bool remaining,
    bool elapse,
    bool selection,
  ) {
    showFull = full;
    showRemaining = remaining;
    showElapsed = elapse;
    allowSelection = selection;
    x = inx;
    y = iny;

    initializeVideo(videoUrl, remaining);
  }

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

  void playVideo() {
    videoPlayerController.play();
    notifyListeners();
  }

  void pauseVideo() {
    videoPlayerController.pause();
    notifyListeners();
  }

  /// Scroll the video to the selected second and update listeners
  void updateFrame(int seconds){

    setLoading(true);

    videoPlayerController
        .seekTo(Duration(seconds: seconds));

    setLoading(false);

    notifyListeners();
  }

  void setLoading(bool val){
    loading = val;
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
