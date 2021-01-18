import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';

/// ImageUtils
class ImageUtils {
  static Future<List<int>> convertImagetoPng(CameraImage image) async {
    try {
      imageLib.Image img;
      if (image.format.group == ImageFormatGroup.yuv420) {
        img = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
      }

      imageLib.PngEncoder pngEncoder = new imageLib.PngEncoder();

      // Convert to png
      List<int> png = pngEncoder.encodeImage(img);
      return png;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  // CameraImage BGRA8888 -> PNG
  // Color
  static imageLib.Image _convertBGRA8888(CameraImage image) {
    return imageLib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imageLib.Format.bgra,
    );
  }

  // CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
  // Black
  static imageLib.Image _convertYUV420(CameraImage image) {
    var img = imageLib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return img;
  }

  static void saveImage(imageLib.Image image, [String i = "0"]) async {
    List<int> jpeg = imageLib.JpegEncoder().encodeImage(image);
    final appDir = await getExternalStorageDirectory();
    final appPath = appDir.path;
    final fileOnDevice = File('$appPath/out$i.jpg');
    await fileOnDevice.writeAsBytes(jpeg, flush: true);
    print('Saved $appPath/out$i.jpg');
  }
}
