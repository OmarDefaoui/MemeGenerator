import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:meme_generator/utils/PermissionsHandler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class SaveToGallery with ChangeNotifier {
  bool isLoading = false, isSavedToGallery = false;

  saveImageToGallery(ScreenshotController screenshotController) async {
    isLoading = true;
    notifyListeners();

    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;
      print('${_image.path}');

      try {
        await GallerySaver.saveImage(_image.path).then((bool result) {
          print('res: $result');

          if (result) isSavedToGallery = true;
          isLoading = false;
          notifyListeners();
        });
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print('error: $onError');
      print(onError);
    });
  }

  askForPermissionToSave(
      BuildContext context, ScreenshotController screenshotController) async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    print('${permissions[PermissionGroup.storage]}');
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted)
      Provider.of<PermissionsHandler>(context, listen: false)
          .showConfirmationDialog(
        context,
        [PermissionGroup.storage],
        'This permission is required to save images to gallery.',
      );
    else
      saveImageToGallery(screenshotController);
  }
}
