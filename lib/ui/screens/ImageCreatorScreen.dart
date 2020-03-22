import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:meme_generator/Constants/Constants.dart';
import 'package:meme_generator/database/DBProvider.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/DraggableWidget.dart';
import 'package:meme_generator/ui/widget/FullScreenMeme.dart';
import 'package:meme_generator/utils/ShowAction.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class ImageCreatorScreen extends StatefulWidget {
  final VoidCallback showBanner;
  final MemeModel memeModel;
  ImageCreatorScreen({
    this.showBanner,
    this.memeModel,
  });

  @override
  _ImageCreatorScreenState createState() => _ImageCreatorScreenState();
}

class _ImageCreatorScreenState extends State<ImageCreatorScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  ScreenshotController screenshotController = ScreenshotController();

  bool _isLoading = false,
      _isSavedToGallery = false,
      _isSavedToFavorite = false;

  //contains meme, and the required draggable widget
  List<Widget> _listStack = [];

  @override
  void initState() {
    super.initState();
    _checkIfExistsInFavorite();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    //add required textbox to list of widget, to display them in a stack widget
    int boxCount = widget.memeModel.boxCount;
    for (int i = 0; i < boxCount; i++) {
      _listStack.add(
        DraggableWidget(
          offset: Offset(0, 64),
          id: boxCount - i,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //to avoid moving widgets when the keywboard was shown
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  //the main screen, wich contains the meme, and the text boxex
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        if (_animationController.isCompleted) {
                          _animationController.reverse();
                        } else {
                          _animationController.forward();
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Screenshot(
                            controller: screenshotController,
                            child: FullScreenMeme(
                              memeModel: widget.memeModel,
                            ),
                          ),
                          Stack(
                            children: _listStack,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //the custom top and bottom appbar
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(0, -_animationController.value * 100),
                          child: Container(
                            height: 64.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      //widget.showBanner();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  customPopUpMenu(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, _animationController.value * 64),
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(
                                            _isSavedToGallery
                                                ? Icons.check_circle_outline
                                                : Icons.save,
                                          ),
                                          onPressed: _isSavedToGallery
                                              ? () {}
                                              : _askForPermission,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: _isSavedToFavorite
                                                  ? Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    )
                                                  : Icon(Icons.favorite_border),
                                              onPressed: _isSavedToFavorite
                                                  ? _removeFromFavorite
                                                  : _saveToFavorite,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.share),
                                              onPressed: _shareImage,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _checkIfExistsInFavorite() async {
    print('check favorite call');

    DBProvider db = DBProvider.db;
    try {
      bool _isExists = await db.isMemeExists(widget.memeModel.id);
      if (_isExists)
        setState(() {
          _isSavedToFavorite = true;
        });
    } catch (e) {}
  }

  Future<void> _saveToFavorite() async {
    print('save to favorite call');

    DBProvider db = DBProvider.db;
    try {
      await db.insertMeme(widget.memeModel);
      setState(() {
        _isSavedToFavorite = true;
      });
    } catch (e) {}
  }

  Future<void> _removeFromFavorite() async {
    print('remove from favorite call');

    DBProvider db = DBProvider.db;
    try {
      await db.deleteMeme(widget.memeModel.id);
      setState(() {
        _isSavedToFavorite = false;
      });
    } catch (e) {}
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

  _askForPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    print('${permissions[PermissionGroup.storage]}');
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted)
      _showConfirmationDialog();
    else
      _saveImageToGallery();
  }

  _showConfirmationDialog() {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Text(
              "This permission is required to save images to gallery.",
            ),
            title: Text("Warning !"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
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

  //function called when we click the back button
  Future<bool> _onWillPop() async {
    //widget.showBanner();
    return true;
  }
}
