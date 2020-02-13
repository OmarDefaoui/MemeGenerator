import 'package:flutter/material.dart';
import 'package:meme_generator/ui/widget/SelectImage.dart';

class PhotoGalleryScreen extends StatefulWidget {
  @override
  _PhotoGalleryScreenState createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SelectImage(),
      ),
    );
  }
}
