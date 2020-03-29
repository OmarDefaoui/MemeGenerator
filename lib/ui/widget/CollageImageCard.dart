import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_generator/ui/widget/BordredText.dart';

class CollageImageCard extends StatefulWidget {
  final int index;
  CollageImageCard({this.index});

  @override
  _CollageImageCardState createState() => _CollageImageCardState();
}

class _CollageImageCardState extends State<CollageImageCard> {
  File _image;
  double _width;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = _displayText();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;

    return Container(
      width: _width / 2,
      height: _width / 2,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: InkWell(
                child: Image(
                  image: _displayImage(),
                ),
                onTap: _handleImage,
              ),
            ),
          ),
          Positioned.fill(
            bottom: _width / 150,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: BorderedText(
                textController: _textController,
                hintText: '',
                fontSize: _width / 18,
                fontWeight: FontWeight.w500,
                strokeColor: Colors.black,
                textColor: Colors.white,
                strokeWidth: _width / 60,
              ),
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

  _displayText() {
    switch (widget.index) {
      case 0:
        return 'Facebook';
      case 1:
        return 'Instagram';
      case 2:
        return 'LinkedIn';
      case 3:
        return 'Tinder';
    }
  }
}
