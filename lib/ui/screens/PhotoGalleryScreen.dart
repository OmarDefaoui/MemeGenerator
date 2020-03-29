import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_generator/database/DBHelper.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/screens/ImageCreatorScreen.dart';
import 'package:provider/provider.dart';

class PhotoGalleryScreen extends StatefulWidget {
  @override
  _PhotoGalleryScreenState createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  File _image;
  TextEditingController _captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    color: Colors.white,
                    child: _image == null
                        ? Container(
                            height: _width,
                            width: _width,
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 150,
                            ),
                          )
                        : Image(
                            image: FileImage(_image),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: _width / 2.5,
                        child: TextField(
                          controller: _captionController,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Text box number',
                          ),
                          maxLength: 1,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      RaisedButton(
                        onPressed: _editImage,
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showSelectImageDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Add photo'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('Choose from gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
    );
  }

  _handleImage(ImageSource source) async {
    Navigator.of(context, rootNavigator: true).pop();
    File imageFile = await ImagePicker.pickImage(source: source);

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
    );

    return croppedImage;
  }

  _editImage() {
    try {
      int number = int.parse(_captionController.text);
      if (number.toString().isEmpty ||
          number > 9 ||
          number < 1 ||
          _image == null) return;

      FocusScope.of(context).unfocus();
      MemeModel memeModel = MemeModel(url: _image.path, boxCount: number);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<DBHelper>(
            create: (context) => DBHelper(),
            child: ImageCreatorScreen(memeModel: memeModel),
          ),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
