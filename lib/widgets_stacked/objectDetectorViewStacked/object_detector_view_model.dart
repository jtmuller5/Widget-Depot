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

class ObjectDetectorViewModel extends BaseViewModel with WidgetsBindingObserver {
  double screenWidth;
  double screenHeight;
  String destination = 'pantry';
  double threshold = .5;

  List<String> pantryCategories = ['Produce', 'Dairy', 'Meat', 'Carbs'];

  bool enableAudio = false;
  bool demo = false; // Show demo image
  String _platformVersion = 'Unknown';
  String _loadModelResult;

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

  String timestamp() =>
      DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();

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

  void incrementDemo() {
    if (demoIndex < demoImages.length - 1) {
      demoIndex++;
    } else {
      demoIndex = 0;
    }
    detectedObjects = demoDetections[demoIndex];
    notifyListeners();
  }

  Future<void> initialize({
    double width,
    double height,
    BuildContext context,
    int startDemo = 0,
  }) async {
    screenWidth = width;
    screenHeight = height;
    demoIndex = startDemo;

    WidgetsBinding.instance.addObserver(this);

    // Create an instance of classifier to load model and labels
    classifier = Classifier();

    // Initially predicting = false
    predicting = false;

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    isolateUtils.start();

    if (!demo) {
      await initializeCamera(context);
    } else {
      detectedObjects = demoDetections[demoIndex];
    }
    notifyListeners();
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera(BuildContext context) async {
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
      Size screenSize = MediaQuery
          .of(context)
          .size;
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

      var uiThreadTimeStart = DateTime
          .now()
          .millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      var isolateData = IsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels);

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic> inferenceResults = await inference(isolateData);

      var uiThreadInferenceElapsedTime =
          DateTime
              .now()
              .millisecondsSinceEpoch - uiThreadTimeStart;

      List<Recognition> holder = inferenceResults['recognitions'];
      List<Recognition> filteredResults = holder.where((element) => element.score > threshold).toList();

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
    detectedObjects = [];
    notifyListeners();
  }

  /* Future<void> initPlatformState(BuildContext context) async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      */ /*_loadModelResult = await Tflite.loadModel(
        model: 'assets/yolov2_tiny.tflite',
        labels: 'assets/yolov2_tiny.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false
      );*/ /*

      */ /*_loadModelResult = await FlutterTflite.loadModel(
         // modelFilePath: 'assets/yolov4-416-fp32.tflite',
          //labelsFilePath: 'assets/ssd_labels.txt',

          modelFilePath: 'assets/groceries-yolov4-tiny-416-01-09-21.tflite',
          labelsFilePath: 'assets/groceries.names',

          //modelFilePath: 'assets/yolov2_tiny.tflite',
          //labelsFilePath: 'assets/ssd_labels.txt',

          isTinyYolo: true,
          useGPU: false);*/ /*

      // Process Image
      // 1 - Convert to byte list
      // 2 - Pass byte list to model

      clearObjects();

      await controller.startImageStream((image) async {
        //clearObjects();
        imageNum++;

        if (imageNum.remainder(100) == 0) {
          detectFrameObjects(image, context);
          //detectFrameObjectsTflite(image);
        }

        //await FlutterTflite.close();
      });

      //platformVersion = await FlutterTflite.platformVersion;
      //await FlutterTF
    } on PlatformException catch (e) {
      print('Detection error: ' + e.message);
      platformVersion = 'Failed to get platform version.';
    }
    notifyListeners();
  }

  Future<void> detectFrameObjectsTflite(CameraImage image) async {
    */ /*var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {return plane.bytes;}).toList(),// required
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,   // defaults to 127.5
        imageStd: 127.5,    // defaults to 127.5
        rotation: 90,       // defaults to 90, Android only
        numResults: 2,      // defaults to 5
        threshold: 0.1,     // defaults to 0.1
        asynch: true        // defaults to true
    );*/ /*

    //print(recognitions.toString());
  }

  Future<void> detectFrameObjects(
      CameraImage image, BuildContext context) async {
    print('image height: ' + image.height.toString());
    print('image width: ' + image.width.toString());

    print('screen height: ' + MediaQuery.of(context).size.height.toString());
    print('screen width: ' + MediaQuery.of(context).size.width.toString());

    print('image format: ' + image.format.raw.toString());

    image.planes.forEach((element) {
      print('plane: ' + element.bytes.toString());
    });

    clearObjects();

    */ /*await FlutterTflite.detectObjectOnFrame(
      imageHeight: image.height,
      imageWidth: image.width,
      rotation: 90,
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
    ).then((detectionResult) {
      print('detection: ' + detectionResult.toString());

      if (detectionResult != '[]' && detectionResult.isNotEmpty) {
        var noBrackets = detectionResult.replaceAll('[', '');
        noBrackets = noBrackets.replaceAll(']', '');

        List<dynamic> jsonDetected = jsonDecode(detectionResult);

        print('Detection result: ' + detectionResult);
        print('Trimmed result: ' + noBrackets);
        print('json result: ' + jsonDetected.toString());

        jsonDetected.forEach((element) {
          DetectedObject object = DetectedObject.fromJson(element);

          print('confidence: ${object.confidence.toString()}');

          /// Add object to detected list only if we are over 80% confident
          if (object.confidence > .85) {
            detectedObjects.add(object);
          }

          notifyListeners();
        });
      }
    });*/ /*
  }*/

  /*Future<void> detectImageObjects(File image) async {
    await FlutterTflite.detectObjectOnImage(imagePath: image.path).then(
          (detectionResult) {
        if (detectionResult != '[]' && detectionResult.isNotEmpty) {
          var noBrackets = detectionResult.replaceAll('[', '');
          noBrackets = noBrackets.replaceAll(']', '');

          List<dynamic> jsonDetected = jsonDecode(detectionResult);

          print('Detection result: ' + detectionResult);
          print('Trimmed result: ' + noBrackets);
          print('json result: ' + jsonDetected.toString());

          jsonDetected.forEach((element) {
            DetectedObject object = DetectedObject.fromJson(element);
            detectedObjects.add(object);
            notifyListeners();
          });
        }
      },
    );
  }*/

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(cameraController != null) {
      cameraController.dispose();
    }
    super.dispose();
  }

  List<String> demoImages = [
    'assets/images/pantry_demo.png',
    'assets/images/dish_demo.png',
    'assets/images/recipe_demo.png',
    'assets/images/barcode_demo.jpg',
  ];

  List<List<Recognition>> demoDetections = [
    // Demo 1 - Pantry
    [
      Recognition(1, 'sour cream', .8,
        Rect.fromLTRB(5, 240, 280, 400),),
      Recognition(2, 'Chobani greek yogurt', .8,
        Rect.fromLTRB(0, 360, 350, 300),),
      Recognition(3, 'lemon', .8,
        Rect.fromLTRB(25, 520, 300, 160),),
      Recognition(1, 'carrots', .8,
        Rect.fromLTRB(270, 600, 50, 70),)
      /*DetectedObject(
        title: 'sour cream',
        confidence: .8,
        location: DetectedLocation(
          bottom: 400,
          top: 240,
          left: 5,
          right: 280,
        ),
      ),*/
      /* DetectedObject(
        title: 'Chobani greek yogurt',
        confidence: .8,
        location: DetectedLocation(
          bottom: 300,
          top: 360,
          left: 0,
          right: 350,
        ),
      ),*/
      /*DetectedObject(
        title: 'lemon',
        confidence: .8,
        location: DetectedLocation(
          bottom: 160,
          top: 520,
          left: 25,
          right: 300,
        ),
      ),*/
      /*DetectedObject(
        title: 'carrots',
        confidence: .8,
        location: DetectedLocation(
          bottom: 70,
          top: 600,
          left: 270,
          right: 50,
        ),
      )*/
    ],
    // Demo 2 - Dish
    [
      Recognition(1, 'sour cream', .8,
        Rect.fromLTRB(5, 240, 280, 400),),
      Recognition(2, 'Chobani greek yogurt', .8,
        Rect.fromLTRB(0, 360, 350, 300),),
      Recognition(3, 'lemon', .8,
        Rect.fromLTRB(25, 520, 300, 160),),
      Recognition(1, 'carrots', .8,
        Rect.fromLTRB(270, 600, 50, 70),)
      /*DetectedObject(
        title: 'tomato',
        confidence: .8,
        location: DetectedLocation(
          bottom: 220,
          top: 450,
          left: 150,
          right: 200,
        ),
      ),
      DetectedObject(
        title: 'nectarine',
        confidence: .8,
        location: DetectedLocation(
          bottom: 460,
          top: 230,
          left: 80,
          right: 230,
        ),
      )*/
    ],
    // Demo 3 - Recipe
    [
      Recognition(1, 'sour cream', .8,
        Rect.fromLTRB(5, 240, 280, 400),),
      Recognition(2, 'Chobani greek yogurt', .8,
        Rect.fromLTRB(0, 360, 350, 300),),
      Recognition(3, 'lemon', .8,
        Rect.fromLTRB(25, 520, 300, 160),),
      Recognition(1, 'carrots', .8,
        Rect.fromLTRB(270, 600, 50, 70),)
      /* DetectedObject(
        title: 'yeast',
        confidence: .8,
        location: DetectedLocation(
          bottom: 400,
          top: 270,
          left: 180,
          right: 140,
        ),
      ),*/
    ],
    // Demo 4 - Barcode
    [
      Recognition(1, 'sour cream', .8,
        Rect.fromLTRB(5, 240, 280, 400),),
      Recognition(2, 'Chobani greek yogurt', .8,
        Rect.fromLTRB(0, 360, 350, 300),),
      Recognition(3, 'lemon', .8,
        Rect.fromLTRB(25, 520, 300, 160),),
      Recognition(1, 'carrots', .8,
        Rect.fromLTRB(270, 600, 50, 70),)
      /* DetectedObject(
        title: 'peanut butter',
        confidence: .8,
        location: DetectedLocation(
          bottom: 300,
          top: 250,
          left: 20,
          right: 20,
        ),
      ),*/
    ],
  ];

  // Object Detection ***********************************************************************
  List<Recognition> detectedObjects = [
    /*DetectedObject(
      title: 'Raspberries',
      confidence: .8,
      location: DetectedLocation(
        bottom: 50,
        top: 200,
        left: 50,
        right: 150,
      ),
    )*/
  ];
}