import 'package:flutter/material.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/DraggableWidget.dart';
import 'package:meme_generator/ui/widget/ShowMeme.dart';

class ImageCreatorScreen extends StatefulWidget {
  final MemeModel memeModel;
  ImageCreatorScreen({this.memeModel});

  @override
  _ImageCreatorScreenState createState() => _ImageCreatorScreenState();
}

class _ImageCreatorScreenState extends State<ImageCreatorScreen> {
  List<Widget> _listStack = [];

  @override
  void initState() {
    super.initState();
    _listStack.add(
      ShowMeme(
        memeModel: widget.memeModel,
      ),
    );
    for (int i = 0; i < widget.memeModel.boxCount; i++) {
      _listStack.add(
        DraggableWidget(
          offset: Offset(0, 0),
        ),
      );
    }
    print(_listStack.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: _width,
          height: _height,
          color: Colors.green,
          child: Stack(
            children: _listStack,
          ),
        ),
      ),
    );
  }
}
