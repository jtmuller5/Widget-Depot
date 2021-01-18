import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/tflite/classifierYolov4.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/tflite/recognition.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/utils/isolate_utils.dart';

import 'tflite/camera_view_singleton.dart';
import 'tflite/stats.dart';

class ObjectDetectorViewModel extends BaseViewModel
    with WidgetsBindingObserver {
  double screenWidth;
  double screenHeight;
  double threshold = .5;

  bool enableAudio = false;

  int demoIndex = 0;
  int imageNum = 0;

  String imagePath;
  String videoPath;

  /// List of available cameras
  List<CameraDescription> cameras;

  /// Controller
  CameraController cameraController;

  /// true when inference is ongoing
  bool predicting;

  /// Instance of [Classifier]
  Classifier classifier;

  /// Instance of [IsolateUtils]
  IsolateUtils isolateUtils;

  /// Results to draw bounding boxes
  List<Recognition> results = [];

  /// Realtime stats
  Stats stats;

  VoidCallback videoPlayerListener;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    this.results = results;
    notifyListeners();
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    this.stats = stats;
    notifyListeners();
  }

  Future<void> initialize({
    @required double width,
    @required double height,
    @required BuildContext context,
  }) async {
    screenWidth = width;
    screenHeight = height;

    WidgetsBinding.instance.addObserver(this);

    // Create an instance of classifier to load model and labels
    classifier = Classifier();

    // Initially predicting = false
    predicting = false;

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    isolateUtils.start();

    await initializeCamera(context);

    notifyListeners();
  }

  /// Initializes the camera by setting [cameraController]
  Future<void> initializeCamera(BuildContext context) async {
    clearObjects();
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController = CameraController(cameras[0], ResolutionPreset.medium,
        enableAudio: false);

    cameraController.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      Size previewSize = cameraController.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;

      if (Platform.isAndroid) {
        // On Android Platform image is initially rotated by 90 degrees
        // due to the Flutter Camera plugin
        CameraViewSingleton.ratio = screenSize.width / previewSize.height;
      } else {
        // For iOS
        CameraViewSingleton.ratio = screenSize.width / previewSize.width;
      }
    });
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier.interpreter != null && classifier.labels != null) {
      // If previous inference has not completed then return
      if (predicting) {
        return;
      }
      predicting = true;
      notifyListeners();

      var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      var isolateData = IsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels);

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic> inferenceResults = await inference(isolateData);

      var uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      List<Recognition> holder = inferenceResults['recognitions'];
      List<Recognition> filteredResults =
          holder.where((element) => element.score > threshold).toList();

      // pass results to HomeView
      resultsCallback(filteredResults);

      // pass stats to HomeView
      statsCallback((inferenceResults['stats'] as Stats)
        ..totalElapsedTime = uiThreadInferenceElapsedTime);
      //widget.imageCallback(inferenceResults["image"]);

      // set predicting to false to allow new frames

      predicting = false;
      notifyListeners();
    }
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        await cameraController.startImageStream(onLatestImageAvailable);
        break;
      default:
    }
  }

  void clearObjects() {
    results = [];
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (cameraController != null) {
      cameraController.dispose();
    }
    super.dispose();
  }
}
