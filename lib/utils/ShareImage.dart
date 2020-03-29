import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:meme_generator/constants/Constants.dart';
import 'package:screenshot/screenshot.dart';

class ShareImage with ChangeNotifier {
  bool isLoading = false;

  shareImage(ScreenshotController screenshotController) async {
    isLoading = true;
    notifyListeners();

    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;

      try {
        await Share.file('Share', 'image_result.png',
            _image.readAsBytesSync().buffer.asUint8List(), 'image/png',
            text: '$shareBody');

        isLoading = false;
        notifyListeners();
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print(onError);
    });
  }
}
