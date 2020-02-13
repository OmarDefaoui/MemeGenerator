import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SelectImage extends StatefulWidget {
  final CropAspectRatio ratio;
  SelectImage({this.ratio});

  @override
  _SelectImageState createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  File _image;
  double _width;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;

    return Container(
      width: _width,
      height: _width,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Image(
                      image: _displayImage(),
                    ),
                  ],
                ),
                onTap: _handleImage,
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.camera_alt,
                    size: 120,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.photo,
                    size: 120,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _displayImage() {
    if (_image != null)
      return FileImage(_image);
    else
      return AssetImage(
        'assets/add.png',
      );
  }

  _handleImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    return croppedImage;
  }
}
