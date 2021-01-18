import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:widget_depot/widgets_stacked/objectDetectorViewStacked/tflite/classifierYolov4.dart';

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

/// Manages separate Isolate instance for inference
class IsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolate";

  // ignore: unused_field
  Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  void start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    final DynamicLibrary convertImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();
    // Load the convertImage() function from the library
    Convert conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      if (isolateData != null) {
        Classifier classifier = Classifier(
            interpreter:
                Interpreter.fromAddress(isolateData.interpreterAddress),
            labels: isolateData.labels);
        //imageLib.Image image =
        //   ImageUtils.convertImagetoPng(isolateData.cameraImage);
        imageLib.Image image;
        if (Platform.isAndroid) {
          // Allocate memory for the 3 planes of the image
          Pointer<Uint8> p =
              allocate(count: isolateData.cameraImage.planes[0].bytes.length);
          Pointer<Uint8> p1 =
              allocate(count: isolateData.cameraImage.planes[1].bytes.length);
          Pointer<Uint8> p2 =
              allocate(count: isolateData.cameraImage.planes[2].bytes.length);

          // Assign the planes data to the pointers of the image
          Uint8List pointerList =
              p.asTypedList(isolateData.cameraImage.planes[0].bytes.length);
          Uint8List pointerList1 =
              p1.asTypedList(isolateData.cameraImage.planes[1].bytes.length);
          Uint8List pointerList2 =
              p2.asTypedList(isolateData.cameraImage.planes[2].bytes.length);
          pointerList.setRange(
              0,
              isolateData.cameraImage.planes[0].bytes.length,
              isolateData.cameraImage.planes[0].bytes);
          pointerList1.setRange(
              0,
              isolateData.cameraImage.planes[1].bytes.length,
              isolateData.cameraImage.planes[1].bytes);
          pointerList2.setRange(
              0,
              isolateData.cameraImage.planes[2].bytes.length,
              isolateData.cameraImage.planes[2].bytes);

          // Call the convertImage function and convert the YUV to RGB
          Pointer<Uint32> imgP = conv(
              p,
              p1,
              p2,
              isolateData.cameraImage.planes[1].bytesPerRow,
              isolateData.cameraImage.planes[1].bytesPerPixel,
              isolateData.cameraImage.planes[0].bytesPerRow,
              isolateData.cameraImage.height);

          // Get the pointer of the data returned from the function to a List
          List imgData = imgP.asTypedList(
              (isolateData.cameraImage.planes[0].bytesPerRow *
                  isolateData.cameraImage.height));
          // Generate image from the converted data
          image = imageLib.Image.fromBytes(isolateData.cameraImage.height,
              isolateData.cameraImage.width, imgData);

          // Free the memory space allocated
          // from the planes and the converted data
          free(p);
          free(p1);
          free(p2);
          free(imgP);
        } else if (Platform.isIOS) {
          image = imageLib.Image.fromBytes(
            isolateData.cameraImage.planes[0].bytesPerRow,
            isolateData.cameraImage.height,
            isolateData.cameraImage.planes[0].bytes,
            format: imageLib.Format.bgra,
          );
        }
        Map<String, dynamic> results = classifier.predict(image);

        isolateData.responsePort.send(results);
      }
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateData {
  CameraImage cameraImage;
  int interpreterAddress;
  List<String> labels;
  SendPort responsePort;

  IsolateData(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  );
}
