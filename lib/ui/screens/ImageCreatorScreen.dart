import 'package:flutter/material.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/DraggableWidget.dart';
import 'package:meme_generator/ui/widget/SelectImage.dart';

class ImageCreatorScreen extends StatefulWidget {
  final MemeModel memeModel;
  ImageCreatorScreen({this.memeModel});

  @override
  _ImageCreatorScreenState createState() => _ImageCreatorScreenState();
}

class _ImageCreatorScreenState extends State<ImageCreatorScreen> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: _width,
          height: _width,
          color: Colors.green,
          child: Stack(
            children: <Widget>[
              SelectImage(),
              DraggableWidget(
                offset: Offset(0,0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
