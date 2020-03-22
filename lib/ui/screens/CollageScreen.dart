import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:meme_generator/Constants/Constants.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:meme_generator/ui/widget/CollageImageCard.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

class CollageScreen extends StatefulWidget {
  @override
  _CollageScreenState createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  double _width, _height = 0;
  ScreenshotController screenshotController = ScreenshotController();
  bool _isLoading = false, _isSavedToGallery = false;

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _askForPermission();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: _width,
                height: _width,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Wrap(
                    children: <Widget>[
                      CollageImageCard(index: 0),
                      CollageImageCard(index: 1),
                      CollageImageCard(index: 2),
                      CollageImageCard(index: 3),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _width / 16,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomCenter,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            _isSavedToGallery ? 'Saved' : "Save to gallery",
                          ),
                          onPressed: _saveImageToGallery,
                        ),
                        RaisedButton(
                          child: Text(
                            "Share",
                          ),
                          onPressed: _shareImage,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _shareImage() async {
    setState(() {
      _isLoading = true;
    });
    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;

      try {
        await Share.file('Share', 'image_result.png',
            _image.readAsBytesSync().buffer.asUint8List(), 'image/png',
            text: '$shareBody');

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  _saveImageToGallery() async {
    setState(() {
      _isLoading = true;
    });

    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;
      print('${_image.path}');

      try {
        GallerySaver.saveImage(_image.path).then((bool result) {
          print('res: $result');
          setState(() {
            if (result) _isSavedToGallery = true;
            _isLoading = false;
          });
        });
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print('error: $onError');
      print(onError);
    });
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  _askForPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    print('${permissions[PermissionGroup.storage]}');
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted)
      _showConfirmationDialog();
  }

  _showConfirmationDialog() {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Text(
              "This permission is required to select and save images to gallery.",
            ),
            title: Text("Warning !"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Accept"),
                onPressed: () {
                  Navigator.pop(context, true);
                  _askForPermission();
                },
              ),
            ],
          );
        });
  }
}
